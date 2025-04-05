import 'dart:io';
import 'dart:convert';

const dataFileName = 'food_data.json';

void main() {
  var foodData = _loadFoodData();

  while (true) {
    print('\nFood Tracker CLI!');
    print('Options:');
    print('1. Enter Meal Data');
    print('2. View Meal Data');
    print('3. Modify Meal Data');
    print('4. Exit');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        foodData = _enterMealData(foodData);
        break;
      case '2':
        _viewMealData(foodData);
        break;
      case '3':
        foodData = _modifyMealData(foodData);
        break;
      case '4':
        _saveFoodData(foodData);
        print('Exiting.');
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Map<String, dynamic> _loadFoodData() {
  final file = File(dataFileName);
  if (file.existsSync()) {
    final contents = file.readAsStringSync();
    return jsonDecode(contents);
  } else {
    return {};
  }
}

void _saveFoodData(Map<String, dynamic> data) {
  final file = File(dataFileName);
  file.writeAsStringSync(jsonEncode(data), flush: true);
  print('Data saved to $dataFileName');
}

Map<String, dynamic> _enterMealData(Map<String, dynamic> data) {
  stdout.write('Enter the date (YYYY-MM-DD): ');
  final date = stdin.readLineSync();
  if (date == null || date.isEmpty) {
    print('Invalid date.');
    return data;
  }

  stdout.write('Enter breakfast: ');
  final breakfast = stdin.readLineSync() ?? '';
  stdout.write('Enter lunch: ');
  final lunch = stdin.readLineSync() ?? '';
  stdout.write('Enter dinner: ');
  final dinner = stdin.readLineSync() ?? '';

  data[date] = {'breakfast': breakfast, 'lunch': lunch, 'dinner': dinner};
  return data;
}

void _viewMealData(Map<String, dynamic> data) {
  stdout.write('Enter the date to view (YYYY-MM-DD): ');
  final date = stdin.readLineSync();
  if (date == null || date.isEmpty) {
    print('Invalid date.');
    return;
  }

  final meals = data[date];
  if (meals != null) {
    print('\n--- Meals for $date ---');
    print('Breakfast: ${meals['breakfast']}');
    print('Lunch: ${meals['lunch']}');
    print('Dinner: ${meals['dinner']}');
    print('------------------------');
  } else {
    print('No data found for $date.');
  }
}

Map<String, dynamic> _modifyMealData(Map<String, dynamic> data) {
  stdout.write('Enter the date to modify (YYYY-MM-DD): ');
  final date = stdin.readLineSync();
  if (date == null || date.isEmpty) {
    print('Invalid date.');
    return data;
  }

  if (!data.containsKey(date)) {
    print('No data found for $date. Please enter data first.');
    return data;
  }

  print('\nWhich meal would you like to modify for $date?');
  print('1. Breakfast');
  print('2. Lunch');
  print('3. Dinner');
  stdout.write('Enter your choice: ');
  final mealChoice = stdin.readLineSync();

  String? mealKey;
  switch (mealChoice) {
    case '1':
      mealKey = 'breakfast';
      break;
    case '2':
      mealKey = 'lunch';
      break;
    case '3':
      mealKey = 'dinner';
      break;
    default:
      print('Invalid meal choice.');
      return data;
  }

  stdout.write('Enter the new value for $mealKey: ');
  final newValue = stdin.readLineSync() ?? '';
  data[date][mealKey] = newValue;
  return data;
}