import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/child_model.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/services/children_services.dart';

class ChildViewModel extends ChangeNotifier {
  final ChildrenServices _childrenService = ChildrenServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Child> _children = [];
  List<Child> get children => _children;
  int childrenCount = 0;

  Child? _child;
  Child? get child => _child;

  String parentUid = '';

  List<UserModel> _parents = [];
  List<UserModel> _filteredParents = [];
  List<UserModel> get parents => _filteredParents;

  List<Map<String, dynamic>> _scheduled = [];
  List<Map<String, dynamic>> get scheduled => _scheduled;

  void getChildById(String id) {
    try {
      _child = _children.firstWhere((child) => child.id == id);
    } catch (e) {
      _child = null;
    } finally {
      notifyListeners();
    }
  }

  Future fetchAllParents() async {
    try {
      _filteredParents = await _childrenService.getAllParents();
      _parents = _filteredParents;
      notifyListeners();
    } catch ($e) {
      print($e);
    } finally {
      notifyListeners();
    }
  }

  Future fetchChildById(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(parentUid)
              .collection('children')
              .doc(id)
              .get();
      _child = Child.fromMap(snapshot.data()!, id);
      notifyListeners();
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  /**
   * Used in the parents_repo. args[uid] is from the parent id.
   * This is called in the health_worker account to fetch all of the children 
   * under the parent.
   * */
  Future<void> fetchAllChildren(String uid) async {
    if (uid.isEmpty) return;
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('children')
              .get();
      _children =
          snapshot.docs
              .map((doc) => Child.fromMap(doc.data(), doc.id))
              .toList();
      _child = _children.first;
    } catch (e) {
      print('Error fetching children: $e');
    }
    notifyListeners();
  }

  void sortParents(String sortBy) {
    if (sortBy == 'name') {
      _filteredParents.sort((a, b) => (a.firstname).compareTo(b.firstname));
    } else if (sortBy == 'address') {
      _filteredParents.sort((b, a) => a.address.compareTo(b.address));
    }
    notifyListeners();
  }

  void filterParents(String query) {
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

  Future<void> markAsComplete(
    String parentUid,
    Child child,
    String vaccineName,
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
        return;
      }

      List<dynamic> updatedSchedule = List.from(childData['schedule']);
      bool updated = false;

      for (var ageGroup in updatedSchedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic> &&
                vaccine['name'] == vaccineName) {
              vaccine['status'] = 'complete';
              updated = true;
              break;
            }
          }
        }
        if (updated) break;
      }

      if (updated) {
        await childDocRef.update({'schedule': updatedSchedule});
        getScheduledChildrenWithVaccines(DateTime.now());
      }
    } catch (e) {
      print('Error marking vaccine as complete: $e');
    } finally {
      notifyListeners();
    }
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

  Map<String, dynamic>? get nextVaccination {
    if (_child?.id == null) return null;
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

  void addChild(
    String uid,
    String lastName,
    String firstName,
    DateTime dob,
  ) async {
    try {
      // Generate the vaccine schedule based on the child's date of birth
      final schedule = _generateVaccineSchedule(dob);
      await _firestore.collection('users').doc(uid).collection('children').add({
        'lastname': lastName,
        'firstname': firstName,
        'dob': Timestamp.fromDate(dob),
        'schedule': schedule,
      });
      fetchChildren();
    } catch (e) {
      print('Error adding child: $e');
    }
    notifyListeners();
  }

  /**
   * This will get the scheduled children with the same date
   * It will be assigned to the _scheduled variable.
   */
  void getScheduledChildrenWithVaccines(DateTime date) async {
    _scheduled = [];
    childrenCount = 0;
    await fetchAllParents();

    // Loop through each parent to correctly fetch and process their children
    for (var parent in _filteredParents) {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(parent.id)
              .collection('children')
              .get();
      _children =
          snapshot.docs
              .map((doc) => Child.fromMap(doc.data(), doc.id))
              .toList();

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
                if (vaccineDate.year == date.year &&
                    vaccineDate.month == date.month) {
                  // Add a map containing the child, vaccine, and parentUid.
                  _scheduled.add({
                    'child': child,
                    'vaccine': vaccine,
                    'parentUid': parent.id,
                  });
                  // We found a due vaccine, no need to check the rest for this child.
                  break;
                }
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  // Used in the children_list of the parent. THe children is fetch using the authenticated user
  Future<void> fetchChildren() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('children')
              .get();
      _children =
          snapshot.docs
              .map((doc) => Child.fromMap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  // --- Business Logic ---
  // A simple, hardcoded list of vaccines and their age-based due dates.
  final List<Map<String, dynamic>> _masterVaccineSchedule = [
    {
      'age': 'Birth',
      'vaccines': [
        {'name': 'BCG', 'due_months': 0},
        {'name': 'Hepatitis B (HepB)-1', 'due_months': 0},
      ],
    },
    {
      'age': '1 1/2 months',
      'vaccines': [
        {'name': 'Pentavalent (DPT-Hep B-HiB)-1', 'due_months': 1.5},
        {'name': 'Oral Polio Vaccine (OPV)-1', 'due_months': 1.5},
        {'name': 'Pneumococcal conjugate (PCV)-1', 'due_months': 1.5},
      ],
    },
    {
      'age': '2 1/2 months',
      'vaccines': [
        {'name': 'Pentavalent (DPT-Hep B-HiB)-2', 'due_months': 2.5},
        {'name': 'Oral Polio Vaccine (OPV)-2', 'due_months': 2.5},
        {'name': 'Pneumococcal conjugate (PCV)-2', 'due_months': 2.5},
      ],
    },
    {
      'age': '3 1/3 months',
      'vaccines': [
        {'name': 'Pentavalent (DPT-Hep B-HiB)-3', 'due_months': 3.3},
        {'name': 'Oral Polio Vaccine (OPV)-3', 'due_months': 3.3},
        {'name': 'Pneumococcal conjugate (PCV)-3', 'due_months': 3.3},
        {'name': 'Inactivated Polio Vaccine (OPV)-1', 'due_months': 3.3},
      ],
    },
    {
      'age': '9 months',
      'vaccines': [
        {'name': 'Inactivated Polio Vaccine (OPV)-2', 'due_months': 9},
        {'name': 'Measles, Mumps, Rubella (MMR)-1', 'due_months': 9},
      ],
    },
    {
      'age': '6-11 months',
      'vaccines': [
        {'name': 'Vitamin A', 'due_months': 11},
      ],
    },
    {
      'age': '12 months',
      'vaccines': [
        {'name': 'Measles, Mumps, Rubella (MMR)-2', 'due_months': 12},
      ],
    },
  ];

  List<Map<String, dynamic>> _generateVaccineSchedule(DateTime dob) {
    final List<Map<String, dynamic>> schedule = [];

    final now = DateTime.now();

    for (var ageGroup in _masterVaccineSchedule) {
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

  Future<void> updateVaccineDate(
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
        return;
      }

      List<dynamic> updatedSchedule = List.from(childData['schedule']);
      bool updated = false;

      for (var ageGroup in updatedSchedule) {
        if (ageGroup is Map<String, dynamic> && ageGroup['vaccines'] is List) {
          for (var vaccine in ageGroup['vaccines']) {
            if (vaccine is Map<String, dynamic> &&
                vaccine['name'] == vaccineName) {
              vaccine['date'] = Timestamp.fromDate(newDate);
              updated = true;
              break;
            }
          }
        }
        if (updated) break;
      }

      if (updated) {
        await childDocRef.update({'schedule': updatedSchedule});
        getScheduledChildrenWithVaccines(DateTime.now());
      } else {
        print('Vaccine $vaccineName not found.');
      }
    } catch (e) {
      print('Error updating vaccine date: $e');
    }
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

  double _calculateComplianceForList() {
    if (children.isEmpty) return 0.0;

    int totalCompleted = 0;
    int totalScheduled = 0;

    for (var childItem in children) {
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

  /// Calculates the overall vaccination compliance across ALL fetched children.
  double get overallComplianceScore {
    return _calculateComplianceForList();
  }
}
