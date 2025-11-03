class Recipe {
  final String title;
  final String description;
  final String imageUrl;
  final List<dynamic> ingredients;
  final List<dynamic> steps;
  final String category;

  Recipe({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
  });

  factory Recipe.fromMap(Map<String, dynamic> data) {
    return Recipe(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      category: data['category'] ?? '',
    );
  }
}
