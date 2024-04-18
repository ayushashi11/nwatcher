import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class EatenFoodItem {
  String name;
  double calories;
  double protein;
  double carbs;
  double fat;
  int quantity;
  EatenFoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
    };
  }
}

class Food {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

Future<Database> initDB() async {
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'food_database2.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) async {
      // Run the CREATE TABLE statement on the database.
      await db.execute(
        'CREATE TABLE daily_food(id INTEGER PRIMARY KEY, type TEXT, time DATETIME)',
      );
      await db.execute(
        'CREATE TABLE eaten_food_item(name TEXT PRIMARY KEY, calories REAL, protein REAL, carbs REAL, fat REAL, quantity INTEGER)',
      );
      await db.execute(
          "CREATE TABLE food(name TEXT PRIMARY KEY, calories REAL, protein REAL, carbs REAL, fat REAL)");
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 5,
  );
}

Future<void> insertFood(Food food) async {
  // Get a reference to the database.
  final db = await initDB();

  // Insert the Dog into the correct table. Also specify the
  // `conflictAlgorithm`. In this case, if the same dog is inserted
  // multiple times, it replaces the previous data.
  await db.insert(
    'food',
    food.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Food>> foods(String name) async {
  // Get a reference to the database.
  final db = await initDB();

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps =
      await db.query('food', where: 'name LIKE ?', whereArgs: [name + '%']);

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Food(
      name: maps[i]['name'],
      calories: maps[i]['calories'],
      protein: maps[i]['protein'],
      carbs: maps[i]['carbs'],
      fat: maps[i]['fat'],
    );
  });
}

Future<List<Food>> foods_all() async {
  final db = await initDB();
  final List<Map<String, dynamic>> maps = await db.query('food');
  return List.generate(maps.length, (i) {
    return Food(
      name: maps[i]['name'],
      calories: maps[i]['calories'],
      protein: maps[i]['protein'],
      carbs: maps[i]['carbs'],
      fat: maps[i]['fat'],
    );
  });
}

Future<void> insertEatenFood(EatenFoodItem food) async {
  final db = await initDB();
  await db.insert(
    'eaten_food_item',
    food.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<EatenFoodItem>> eatenFoods() async {
  final db = await initDB();
  final List<Map<String, dynamic>> maps = await db.query('eaten_food_item');
  return List.generate(maps.length, (i) {
    return EatenFoodItem(
      name: maps[i]['name'],
      calories: maps[i]['calories'],
      protein: maps[i]['protein'],
      carbs: maps[i]['carbs'],
      fat: maps[i]['fat'],
      quantity: maps[i]['quantity'],
    );
  });
}

Future<void> addEatenFoodItem(String name) async {
  //check if already exists in the db and increment quantity, else get nutrition info and add to db
  final db = await initDB();
  final List<Map<String, dynamic>> maps =
      await db.query('eaten_food_item', where: 'name = ?', whereArgs: [name]);
  if (maps.length == 0) {
    final List<Map<String, dynamic>> food =
        await db.query('food', where: 'name = ?', whereArgs: [name]);
    if (food.length == 0) {
      return;
    }
    EatenFoodItem eatenFoodItem = EatenFoodItem(
        name: food[0]['name'],
        calories: food[0]['calories'],
        protein: food[0]['protein'],
        carbs: food[0]['carbs'],
        fat: food[0]['fat'],
        quantity: 1);
    insertEatenFood(eatenFoodItem);
  } else {
    await db.update('eaten_food_item', {'quantity': maps[0]['quantity'] + 1},
        where: 'name = ?', whereArgs: [name]);
  }
}

Future<void> reduceEatenFoodQuantity(String name) async {
  final db = await initDB();
  final List<Map<String, dynamic>> maps =
      await db.query('eaten_food_item', where: 'name = ?', whereArgs: [name]);
  if (maps.length == 0) {
    return;
  }
  if (maps[0]['quantity'] == 1) {
    await db.delete('eaten_food_item', where: 'name = ?', whereArgs: [name]);
  } else {
    await db.update('eaten_food_item', {'quantity': maps[0]['quantity'] - 1},
        where: 'name = ?', whereArgs: [name]);
  }
}

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.

  insertFood(
      Food(name: 'apple', calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2));
  insertFood(
      Food(name: 'banana', calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3));
  insertFood(
      Food(name: 'orange', calories: 62, protein: 1.2, carbs: 15.4, fat: 0.2));
  insertFood(
      Food(name: 'milk', calories: 42, protein: 3.4, carbs: 5.1, fat: 1.0));
  insertFood(
      Food(name: 'bread', calories: 265, protein: 9.4, carbs: 49.4, fat: 2.7));

  insertEatenFood(EatenFoodItem(
      name: "apple",
      calories: 52,
      protein: 0.3,
      carbs: 13.8,
      fat: 0.2,
      quantity: 2));
}
