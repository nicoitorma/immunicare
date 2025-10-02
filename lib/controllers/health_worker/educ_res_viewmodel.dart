import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/educ_res_model.dart';

class EducResViewmodel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<EducResModel> _articles = [];
  List<EducResModel> get articles => _articles;
  List<EducResModel> _filteredArticles = [];
  List<EducResModel> get filteredArticles => _filteredArticles;

  Future getAllArticles() async {
    try {
      final snapshot = await _firestore.collection('educationals').get();
      _articles =
          snapshot.docs
              .map((doc) => EducResModel.fromMap(doc.data(), doc.id))
              .toList();
      _filteredArticles = _articles;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void sortArticles(String sortBy) {
    if (sortBy == 'title') {
      _filteredArticles.sort((a, b) => (a.title).compareTo(b.title));
    } else if (sortBy == 'category') {
      _filteredArticles.sort((a, b) => (a.category).compareTo(b.category));
    }
    notifyListeners();
  }

  Future uploadNewArticle(EducResModel educational) async {
    try {
      _firestore.collection('educationals').add(educational.toMap());
      _articles.add(educational);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> editArticle(EducResModel newEducational) async {
    try {
      await _firestore
          .collection('educationals')
          .doc(newEducational.id)
          .update(newEducational.toMap());

      final index = _articles.indexWhere((doc) => doc.id == newEducational.id);
      if (index != -1) {
        _articles[index] = newEducational;
      }
    } catch (e) {
      debugPrint('Error editing educational resource: $e');
    } finally {
      notifyListeners();
    }
  }

  Future deleteArticle(String docId) async {
    try {
      _firestore.collection('educationals').doc(docId).delete();
      final index = _articles.indexWhere((doc) => doc.id == docId);

      if (index != -1) {
        _articles.removeAt(index);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
