import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:immunicare/models/child_model.dart';
import 'package:immunicare/models/immunization_record_model.dart';
import 'package:immunicare/services/firestore_services.dart';

// ViewModel to manage child-related operations and state. This is managed using Provider for state management.
// It interacts with FirestoreService to perform CRUD operations and listens for real-time updates.
// It is used in the parent account dashboard and vaccination records screens.
class ChildViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<Child> _children = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Child> get children => _children;

  // Stream subscription to listen for real-time updates.
  Stream<List<Child>>? _childrenStream;

  // Initializes the stream to listen for child data.
  void listenToChildren(String parentUid) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _childrenStream =
        _firestoreService
                .getChildrenForParent(parentUid)
                .listen(
                  (children) {
                    _children = children;
                    _isLoading = false;
                    notifyListeners();
                  },
                  onError: (e) {
                    _errorMessage = 'Failed to load children: $e';
                    _isLoading = false;
                    notifyListeners();
                  },
                )
            as Stream<List<Child>>?;
  }

  @override
  void dispose() {
    _childrenStream = null;
    _childrenStream?.drain();
    super.dispose();
  }

  Future<void> signUpChild({
    required String name,
    required DateTime dateOfBirth,
    required String parentUid,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String newChildId =
          FirebaseFirestore.instance.collection('children').doc().id;

      // Define an initial set of vaccines and vitamins.
      final List<ImmunizationRecord> initialVaccines = [
        ImmunizationRecord(name: 'BCG', isAdministered: false),
        ImmunizationRecord(name: 'Polio', isAdministered: false),
      ];
      final List<ImmunizationRecord> initialVitamins = [
        ImmunizationRecord(name: 'Vitamin A', isAdministered: false),
        ImmunizationRecord(name: 'Vitamin D', isAdministered: false),
      ];

      final newChild = Child(
        id: newChildId,
        name: name,
        dateOfBirth: dateOfBirth,
        parentUid: parentUid,
        vaccines: initialVaccines,
        vitamins: initialVitamins,
      );

      await _firestoreService.addChild(newChild);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to sign up child. Please try again.';
      notifyListeners();
    }
  }

  // Method to update the immunization status for a child.
  Future<void> updateImmunizationStatus({
    required String childId,
    required List<ImmunizationRecord> vaccines,
    required List<ImmunizationRecord> vitamins,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateImmunizationStatus(
        childId,
        vaccines,
        vitamins,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update immunization status.';
      notifyListeners();
    }
  }
}
