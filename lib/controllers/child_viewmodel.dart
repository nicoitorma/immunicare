import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/models/child_model.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<Child>> childrenByParentId = {};
  List<Child> getChildrenForParent(String parentId) =>
      childrenByParentId[parentId] ?? [];

  Child? _child;
  Child? get child => _child;

  List<Child> _children = [];
  List<Child> get children => _children;

  String parentUid = '';
  String get uid => _auth.currentUser?.uid ?? '';

  List<UserModel> _parents = [];
  List<UserModel> get parents => _parents;
  List<UserModel> _filteredParents = [];
  List<UserModel> get filteredParents => _filteredParents;

  List<Map<String, dynamic>> _scheduled = [];
  List<Map<String, dynamic>> get scheduled => _scheduled;

  int childrenCount = 0;

  void sortParents(String sortBy) {
    if (sortBy == 'name') {
      _parents.sort((a, b) => (a.firstname).compareTo(b.firstname));
    } else if (sortBy == 'address') {
      _parents.sort((b, a) => a.address.compareTo(b.address));
    }
    notifyListeners();
  }

  /// Fetch children for a specific parent and cache them
  /// Used in the parents_repo.dart to display the list of children under a parent.
  Future getChildrenByParentId(String parentId) async {
    if (parentId.isEmpty) return;
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(parentId)
              .collection('children')
              .get();
      _children =
          snapshot.docs
              .map((doc) => Child.fromMap(doc.data(), doc.id))
              .toList();
      childrenByParentId[parentId] = children;
      if (children.isNotEmpty) {
        _child = children.first;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  /// Fetch a specific child by parentId and childId.
  /// Used in the parents_repo.dart when tapping a child item.
  Future getChildById({required String childId}) async {
    if (childId.isEmpty) return;

    try {
      _child = children.firstWhere((c) => c.id == childId);
      notifyListeners();
    } catch (e) {
      print('Error fetching children: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Fetch all parents (health worker use case)
  /// Used in the parents_repo.dart to display all parents.
  Future getAllParents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = await prefs.getString('address');
      final QuerySnapshot usersSnapshot =
          await _firestore
              .collection('users')
              .where('address', isEqualTo: address)
              .get();

      _parents =
          usersSnapshot.docs.map((doc) {
            return UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      _parents.removeWhere((user) => user.role == 'super_admin');

      notifyListeners();
    } catch (e) {
      print(e);
      return <UserModel>[];
    }
  }

  /// Fetch all children across all parents
  /// Used in the dashboard to calculate overall compliance score
  Future getAllChildren() async {
    try {
      final QuerySnapshot usersSnapshot =
          await _firestore.collectionGroup('children').get();

      _children =
          usersSnapshot.docs.map((doc) {
            return Child.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      notifyListeners();
      return children;
    } catch (e) {
      print(e);
      return <Child>[];
    }
  }

  void searchParent(String query) {
    if (query.isEmpty) {
      _filteredParents = List.from(_parents);
    } else {
      _filteredParents =
          _filteredParents
              .where(
                (parent) =>
                    parent.firstname.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    parent.lastname.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    parent.address.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    notifyListeners();
  }

  Future<String> markAsComplete({
    String? parentUid,
    Child? child,
    String? vaccineName,
    String? administeredBy,
  }) async {
    final childId = child?.id;
    final childDocRef = _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId);

    try {
      final docSnapshot = await childDocRef.get();
      final childData = docSnapshot.data();
      if (childData == null || !childData.containsKey('schedule')) {
        return 'Schedule data not found for child: $childId';
      }

      List<dynamic> updatedSchedule = List.from(childData['schedule']);
      bool updated = false;

      for (var ageGroup in updatedSchedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic> &&
                vaccine['name'] == vaccineName) {
              vaccine['status'] = 'complete';
              vaccine['administeredBy'] = administeredBy;
              vaccine['administeredAt'] = Timestamp.now();
              updated = true;
              break;
            }
          }
        }
        if (updated) break;
      }

      if (updated) {
        await childDocRef.update({'schedule': updatedSchedule});
        _child = Child.fromMap({
          ...childData,
          'schedule': updatedSchedule,
        }, childId!);
        _scheduled.removeWhere(
          (entry) =>
              entry['child'].id == child!.id &&
              entry['vaccine']['name'] == vaccineName,
        );

        return '${vaccineName} vaccine for ${child!.firstname} marked as complete.';
      }
    } catch (e) {
      return 'Error marking vaccine as complete: $e';
    } finally {
      notifyListeners();
    }
    return '${vaccineName} vaccine not found in schedule.';
  }

  Map<String, dynamic>? nextVaccine(Child child) {
    if (_child?.id == null) return null;
    final scheduleData = child.schedule;
    for (var ageGroup in scheduleData) {
      if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
        for (var vaccine in ageGroup['vaccines']) {
          if (vaccine is Map<String, dynamic> &&
              (vaccine['status'] == 'due' || vaccine['status'] == 'upcoming')) {
            return vaccine;
          }
        }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _generateVaccineSchedule(DateTime dob) {
    final List<Map<String, dynamic>> schedule = [];

    final now = DateTime.now();

    for (var ageGroup in masterVaccineSchedule) {
      final List<Map<String, dynamic>> vaccinesForAgeGroup = [];
      final double dueMonths =
          (ageGroup['vaccines'][0]['due_months'] as num).toDouble();

      final int wholeMonths = dueMonths.floor();
      final double fractionalMonths = dueMonths - wholeMonths;
      final int extraDays = (fractionalMonths * 30).round();
      DateTime dueDate = DateTime(dob.year, dob.month + wholeMonths, dob.day);
      dueDate = dueDate.add(Duration(days: extraDays));
      final status = dueDate.isBefore(now) ? 'due' : 'upcoming';

      for (var vaccine in ageGroup['vaccines']) {
        vaccinesForAgeGroup.add({
          'name': vaccine['name'],
          'status': status,
          'date': Timestamp.fromDate(dueDate),
        });
      }
      schedule.add({'age': ageGroup['age'], 'vaccines': vaccinesForAgeGroup});
    }

    return schedule;
  }

  Future<String> updateVaccineDate(
    String parentUid,
    Child child,
    String vaccineName,
    DateTime newDate,
  ) async {
    final childId = child.id;
    final childDocRef = _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId);

    try {
      final docSnapshot = await childDocRef.get();
      final childData = docSnapshot.data();

      if (childData == null || !childData.containsKey('schedule')) {
        print('Schedule data not found for child: $childId');
        return 'Schedule data not found for child: ${child.firstname}';
      }

      final childBaseId = childId.hashCode.abs() % 1000000;
      int notificationIndex = 0;

      List<dynamic> updatedSchedule = List.from(childData['schedule']);
      bool updated = false;

      for (var ageGroup in updatedSchedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic>) {
              final notificationId = (childBaseId * 100) + notificationIndex;
              notificationIndex++;

              if (vaccine['name'] == vaccineName) {
                vaccine['date'] = Timestamp.fromDate(newDate);
                updated = true;

                // Cancel and reschedule notifications
                await NotificationService().cancelNotification(notificationId);
                await NotificationService().scheduleVaccinationReminder(
                  id: notificationId,
                  childName: child.firstname,
                  vaccinationName: vaccineName,
                  scheduleDate: newDate,
                );
              }
            }
          }
        }
        if (updated) break;
      }

      if (updated) {
        // --- Update Firestore ---
        await childDocRef.update({'schedule': updatedSchedule});

        // --- Update local state ---
        for (var entry in _scheduled) {
          if (entry['child'].id == child.id &&
              entry['vaccine']['name'] == vaccineName) {
            entry['vaccine']['date'] = Timestamp.fromDate(newDate);
            break;
          }
        }
        notifyListeners();

        print(
          'Vaccine date and status successfully updated for $vaccineName. Notification rescheduled.',
        );
        return 'Vaccine date for ${child.firstname} updated successfully.';
      } else {
        print('Warning: Vaccine "$vaccineName" not found in schedule.');
      }
    } catch (e) {
      print('Error updating vaccine date: $e');
    }

    return 'Vaccine "$vaccineName" not found in schedule for ${child.firstname}.';
  }

  Map<String, dynamic>? get nextVaccination {
    if (_child?.id == null) {
      _child = children.isNotEmpty ? children.first : null;
    }
    final scheduleData = _child!.schedule;
    for (var ageGroup in scheduleData) {
      if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
        for (var vaccine in ageGroup['vaccines']) {
          if (vaccine is Map<String, dynamic> &&
              (vaccine['status'] == 'due' || vaccine['status'] == 'upcoming')) {
            return vaccine;
          }
        }
      }
    }
    return null;
  }

  int calculateAgeInMonths(Timestamp dobTimestamp) {
    final dob = dobTimestamp.toDate();
    final now = DateTime.now();

    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (now.day < dob.day) {
      months--;
    }
    return (years * 12) + months;
  }

  double calculateProgress(Timestamp dueDate) {
    final now = DateTime.now();
    final due = dueDate.toDate();
    final totalTime = due.difference(now).inDays;
    final progress = (90 - totalTime) / 90;
    return progress.clamp(0.0, 1.0);
  }

  double get complianceScore {
    if (_child == null || _child!.schedule.isEmpty) {
      return 0.0;
    }

    int totalVaccines = 0;
    int completedVaccines = 0;

    for (var ageGroup in _child!.schedule) {
      if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
        for (var vaccine in ageGroup['vaccines']) {
          if (vaccine is Map<String, dynamic>) {
            // Only count vaccines that are due or completed. Ignore "upcoming" for current compliance.
            if (vaccine['status'] == 'complete' || vaccine['status'] == 'due') {
              totalVaccines++;
              if (vaccine['status'] == 'complete') {
                completedVaccines++;
              }
            }
          }
        }
      }
    }

    if (totalVaccines == 0) return 1.0;

    return completedVaccines / totalVaccines;
  }

  void addChild(
    String uid,
    String lastName,
    String firstName,
    DateTime dob,
    String barangay,
  ) async {
    try {
      // Generate the vaccine schedule based on the child's date of birth
      final schedule = _generateVaccineSchedule(dob);
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('children')
          .add({
            'lastname': lastName,
            'firstname': firstName,
            'parentId': uid,
            'dob': Timestamp.fromDate(dob),
            'schedule': schedule,
            'createdAt': FieldValue.serverTimestamp(),
            'barangay': barangay,
            'status': 'active',
          });
      final String childDocId = docRef.id;

      // 4. Schedule Notifications for all 'upcoming' vaccines
      await _scheduleUpcomingVaccineNotifications(
        childName: firstName,
        childDocId: childDocId,
        schedule: schedule,
      );

      getChildrenByParentId(uid);
      notifyListeners();
    } catch (e) {
      print('Error adding child: $e');
    }
    notifyListeners();
  }

  Future<void> _scheduleUpcomingVaccineNotifications({
    required String childName,
    required String childDocId,
    required List<Map<String, dynamic>> schedule,
  }) async {
    // Generate a base ID from the document ID hash.
    // We limit the hash size to avoid overflow and use it as a unique prefix.
    final int childBaseId = childDocId.hashCode.abs() % 1000000;
    int notificationIndex = 0;

    for (var ageGroup in schedule) {
      for (var vaccine in ageGroup['vaccines']) {
        if (vaccine['status'] == 'upcoming' || vaccine['status'] == 'due') {
          final String vaccineName = vaccine['name'];
          final DateTime dueDate = (vaccine['date'] as Timestamp).toDate();
          final int notificationId = (childBaseId * 100) + notificationIndex;

          await NotificationService().scheduleVaccinationReminder(
            id: notificationId,
            childName: childName,
            vaccinationName: vaccineName,
            scheduleDate: dueDate,
          );

          notificationIndex++;
        }
      }
    }
  }

  /**
     * This will get the scheduled children with the same date
     * It will be assigned to the _scheduled variable.
     */
  Future getScheduledChildrenWithVaccines(DateTime date) async {
    _scheduled.clear();
    childrenCount = 0;

    // Loop through each parent to correctly fetch and process their children
    try {
      for (var child in _children) {
        final scheduleData = child.schedule;
        childrenCount += 1;
        for (var ageGroup in scheduleData) {
          if (ageGroup is Map<String, dynamic> &&
              ageGroup['vaccines'] is List) {
            for (var vaccine in ageGroup['vaccines']) {
              if (vaccine is Map<String, dynamic> &&
                  vaccine['status'] == 'due') {
                final vaccineDate = (vaccine['date'] as Timestamp).toDate();

                if ((vaccineDate.year == date.year &&
                        vaccineDate.month == date.month) ||
                    vaccineDate.isBefore(date)) {
                  // Add a map containing the child, vaccine, and parentUid.
                  _scheduled.add({
                    'child': child,
                    'vaccine': vaccine,
                    'parentId': child.parentId,
                  });
                  // We found a due vaccine, no need to check the rest for this child.
                  break;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching scheduled children: $e');
    }

    notifyListeners();
  }

  double _calculateComplianceForList(List<Child> childrenList) {
    if (childrenList.isEmpty) return 0.0;

    int totalCompleted = 0;
    int totalScheduled = 0;

    for (var childItem in childrenList) {
      for (var ageGroup in childItem.schedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic>) {
              totalScheduled++;
              if (vaccine['status'] == 'complete') {
                totalCompleted++;
              }
            }
          }
        }
      }
    }

    if (totalScheduled == 0) return 0.0;

    // Return compliance score as a percentage (0.0 to 100.0)
    return (totalCompleted / totalScheduled) * 100;
  }

  /// Returns a list of unique barangay names from all registered children.
  List<String> getUniqueBarangays() {
    if (_children.isEmpty) return [];
    // Assuming 'barangay' field exists on Child model
    return _children
        .map((child) => child.barangay)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Counts the total number of children registered in a specific barangay.
  int getTotalChildrenByBarangay(String barangayName) {
    if (_children.isEmpty || barangayName.isEmpty) return 0;
    return _children
        .where(
          (child) => child.barangay.toLowerCase() == barangayName.toLowerCase(),
        )
        .length;
  }

  /// Counts the number of children in a barangay that are fully vaccinated.
  int getFullyVaccinatedCountByBarangay(String barangayName) {
    if (_children.isEmpty || barangayName.isEmpty) return 0;

    final filteredChildren =
        _children
            .where(
              (child) =>
                  child.barangay.toLowerCase() == barangayName.toLowerCase(),
            )
            .toList();

    return filteredChildren
        .where((child) => _isChildFullyVaccinated(child))
        .length;
  }

  /// Counts the number of children in a barangay that are NOT fully vaccinated.
  int getIncompletelyVaccinatedCountByBarangay(String barangayName) {
    if (_children.isEmpty || barangayName.isEmpty) return 0;

    final filteredChildren =
        _children
            .where(
              (child) =>
                  child.barangay.toLowerCase() == barangayName.toLowerCase(),
            )
            .toList();

    // Count where the child is NOT fully vaccinated (i.e., has at least one due/upcoming vaccine)
    return filteredChildren
        .where((child) => !_isChildFullyVaccinated(child))
        .length;
  }

  /// Counts the total number of vaccines marked 'due' in a specific barangay.
  int getTotalOverdueByBarangay(String barangayName) {
    if (_children.isEmpty || barangayName.isEmpty) return 0;

    final filteredChildren =
        _children
            .where(
              (child) =>
                  child.barangay.toLowerCase() == barangayName.toLowerCase(),
            )
            .toList();

    int overdueCount = 0;
    for (var childItem in filteredChildren) {
      for (var ageGroup in childItem.schedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic> && vaccine['status'] == 'due') {
              overdueCount++;
            }
          }
        }
      }
    }
    return overdueCount;
  }

  double getComplianceScoreByBarangay(String barangayName) {
    if (_children.isEmpty || barangayName.isEmpty) return 0.0;

    // Filter the master list of children by the specified barangay name.
    final filteredChildren =
        _children.where((child) {
          // Assuming Child model has a 'barangay' property
          return child.barangay.toLowerCase() == barangayName.toLowerCase();
        }).toList();

    return _calculateComplianceForList(filteredChildren);
  }

  /// Helper to check if a single child has completed ALL vaccines in their schedule.
  bool _isChildFullyVaccinated(Child child) {
    if (child.schedule.isEmpty) return false;

    for (var ageGroup in child.schedule) {
      if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
        for (var vaccine in ageGroup['vaccines']) {
          if (vaccine is Map<String, dynamic> &&
              vaccine['status'] != 'complete') {
            // Found at least one vaccine that is not complete
            return false;
          }
        }
      }
    }
    // All vaccines checked are complete
    return true;
  }

  /// Calculates the overall vaccination compliance across ALL fetched children.
  double get overallComplianceScore {
    return _calculateComplianceForList(children);
  }

  /// Create notification services for vaccination schedules
  Future<void> createNotificationService() async {
    // Notification scheduling logic

    notifyListeners();
  }
}
