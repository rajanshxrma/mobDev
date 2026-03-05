// sample recipe data for the app
import '../models/recipe.dart';

// list of sample recipes
final List<Recipe> sampleRecipes = [
  Recipe(
    name: 'Spaghetti Marinara',
    imagePath: 'assets/images/pasta.png',
    ingredients: [
      '8 oz spaghetti',
      '2 cups marinara sauce',
      '2 cloves garlic',
      '1 tbsp olive oil',
      'fresh basil leaves',
      'parmesan cheese',
    ],
    instructions:
        '1. boil water and cook spaghetti according to package directions.\n'
        '2. heat olive oil in a pan and saute garlic for 1 minute.\n'
        '3. add marinara sauce and simmer for 10 minutes.\n'
        '4. drain pasta and toss with the sauce.\n'
        '5. top with fresh basil and parmesan cheese.',
  ),
  Recipe(
    name: 'Garden Salad',
    imagePath: 'assets/images/salad.png',
    ingredients: [
      'mixed greens',
      'cherry tomatoes',
      '1 cucumber',
      'red onion slices',
      'vinaigrette dressing',
      'salt and pepper',
    ],
    instructions:
        '1. wash and dry all the greens.\n'
        '2. slice cherry tomatoes in half.\n'
        '3. peel and slice the cucumber into thin rounds.\n'
        '4. thinly slice the red onion.\n'
        '5. toss everything together in a large bowl.\n'
        '6. drizzle with vinaigrette and season with salt and pepper.',
  ),
  Recipe(
    name: 'Grilled Cheese Sandwich',
    imagePath: 'assets/images/grilled_cheese.png',
    ingredients: [
      '2 slices bread',
      '2 slices cheddar cheese',
      '1 tbsp butter',
    ],
    instructions:
        '1. butter one side of each bread slice.\n'
        '2. place one slice butter-side down in a pan over medium heat.\n'
        '3. add cheese slices on top.\n'
        '4. place second bread slice butter-side up on top.\n'
        '5. cook until golden brown, about 3 minutes per side.\n'
        '6. flip carefully and cook the other side until cheese is melted.',
  ),
  Recipe(
    name: 'Chocolate Chip Pancakes',
    imagePath: 'assets/images/pancakes.png',
    ingredients: [
      '1 cup flour',
      '1 egg',
      '3/4 cup milk',
      '2 tbsp sugar',
      '1 tsp baking powder',
      '1/2 cup chocolate chips',
      'maple syrup',
    ],
    instructions:
        '1. mix flour, sugar, and baking powder in a bowl.\n'
        '2. add egg and milk, stir until just combined.\n'
        '3. fold in chocolate chips.\n'
        '4. heat a non-stick pan over medium heat.\n'
        '5. pour batter and cook until bubbles form on top.\n'
        '6. flip and cook for another minute.\n'
        '7. serve with maple syrup and fresh berries.',
  ),
  Recipe(
    name: 'Chicken Stir Fry',
    imagePath: 'assets/images/stir_fry.png',
    ingredients: [
      '1 lb chicken breast',
      '1 red bell pepper',
      '1 cup broccoli florets',
      '1 carrot',
      '2 tbsp soy sauce',
      '1 tbsp sesame oil',
      'cooked rice for serving',
    ],
    instructions:
        '1. cut chicken into bite-sized pieces.\n'
        '2. slice bell pepper, carrot, and broccoli.\n'
        '3. heat sesame oil in a wok over high heat.\n'
        '4. cook chicken until browned, about 5 minutes.\n'
        '5. add vegetables and stir fry for 3 minutes.\n'
        '6. add soy sauce and toss to coat.\n'
        '7. serve hot over cooked rice.',
  ),
];
