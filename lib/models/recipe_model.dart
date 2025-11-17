import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? id;
  final String title;
  final String description;
  final String imageUrl;
  final List<dynamic> ingredients;
  final List<dynamic> steps;
  final String category;
  final String userId; // ID của người tạo công thức
  final String? userName; // Tên người tạo (optional)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.userId,
    this.userName,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> data, String docId) {
    return Recipe(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'userId': userId,
      if (userName != null) 'userName': userName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<dynamic>? ingredients,
    List<dynamic>? steps,
    String? category,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
