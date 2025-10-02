class EducResModel {
  final String? id;
  final String title;
  final String category;
  final String content;

  EducResModel({
    this.id,
    required this.title,
    required this.category,
    required this.content,
  });

  // Factory constructor to create a User from Firestore document.
  factory EducResModel.fromMap(Map<String, dynamic> data, String id) {
    return EducResModel(
      id: id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      content: data['content'] ?? '',
    );
  }

  // Converts a User object into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'category': category, 'content': content};
  }
}
