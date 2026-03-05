// recipe model class to store recipe data
class Recipe {
  final String name;
  final String imagePath;
  final List<String> ingredients;
  final String instructions;

  // constructor with required fields
  Recipe({
    required this.name,
    required this.imagePath,
    required this.ingredients,
    required this.instructions,
  });
}
