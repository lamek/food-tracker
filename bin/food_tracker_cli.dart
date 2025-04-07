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
        foodData = _enterMealDataInteractive(foodData);
        break;
      case '2':
        _viewMealDataInteractive(foodData);
        break;
      case '3':
        foodData = _modifyMealDataInteractive(foodData);
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

String _formatDate(DateTime date) {
  return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
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

Map<String, dynamic> _enterMealDataInteractive(Map<String, dynamic> data) {
  DateTime currentDate = DateTime.now();
  while (true) {
    print('\nEntering Meal Data for: ${_formatDate(currentDate)}');
    stdout.write('(n)ext day, (p)revious day, (o)kay to enter: ');
    final action = stdin.readLineSync()?.toLowerCase();

    if (action == 'n') {
      currentDate = currentDate.add(Duration(days: 1));
    } else if (action == 'p') {
      currentDate = currentDate.subtract(Duration(days: 1));
    } else if (action == 'o') {
      final dateStr = _formatDate(currentDate);
      stdout.write('Enter breakfast: ');
      final breakfast = stdin.readLineSync() ?? '';
      stdout.write('Enter lunch: ');
      final lunch = stdin.readLineSync() ?? '';
      stdout.write('Enter dinner: ');
      final dinner = stdin.readLineSync() ?? '';
      data[dateStr] = {'breakfast': breakfast, 'lunch': lunch, 'dinner': dinner};
      return data;
    } else {
      print('Invalid action. Use "n", "p", or "o".');
    }
  }
}

void _viewMealDataInteractive(Map<String, dynamic> data) {
  DateTime currentDate = DateTime.now();
  while (true) {
    print('\nViewing Meal Data (Last 7 Days)');
    print('Current Date: ${_formatDate(currentDate)}');
    print('(n)ext day, (p)revious day, (s)ee week, (q)uit view: ');
    final action = stdin.readLineSync()?.toLowerCase();

    if (action == 'n') {
      currentDate = currentDate.add(Duration(days: 1));
    } else if (action == 'p') {
      currentDate = currentDate.subtract(Duration(days: 1));
    } else if (action == 's') {
      _displayLast7Days(data, currentDate);
    } else if (action == 'q') {
      return; // Exit view mode
    } else {
      print('Invalid action. Use "n", "p", "s", or "q".');
    }
  }
}

void _displayLast7Days(Map<String, dynamic> data, DateTime endDate) {
  print('\n--- Last 7 Days ---');
  for (int i = 6; i >= 0; i--) {
    final date = endDate.subtract(Duration(days: i));
    final dateStr = _formatDate(date);
    final meals = data[dateStr];
    print('\n${dateStr}:');
    if (meals != null) {
      print('  Breakfast: ${meals['breakfast']}');
      print('  Lunch: ${meals['lunch']}');
      print('  Dinner: ${meals['dinner']}');
    } else {
      print('  No data');
    }
  }
  print('-------------------\n');
}

// void _viewMealDataInteractive(Map<String, dynamic> data) {
//   DateTime currentDate = DateTime.now();
//   while (true) {
//     final currentDateStr = _formatDate(currentDate);
//     print('\nViewing Meal Data for: $currentDateStr');
//     stdout.write('(n)ext day, (p)revious day, (o)kay to view: ');
//     final action = stdin.readLineSync()?.toLowerCase();

//     if (action == 'n') {
//       currentDate = currentDate.add(Duration(days: 1));
//     } else if (action == 'p') {
//       currentDate = currentDate.subtract(Duration(days: 1));
//     } else if (action == 'o') {
//       final meals = data[currentDateStr];
//       if (meals != null) {
//         print('\n--- Meals for $currentDateStr ---');
//         print('Breakfast: ${meals['breakfast']}');
//         print('Lunch: ${meals['lunch']}');
//         print('Dinner: ${meals['dinner']}');
//         print('------------------------------');
//       } else {
//         print('No data found for $currentDateStr.');
//       }
//       return; // Exit view mode after viewing
//     } else {
//       print('Invalid action. Use "n", "p", or "o".');
//     }
//   }
// }

Map<String, dynamic> _modifyMealDataInteractive(Map<String, dynamic> data) {
  DateTime currentDate = DateTime.now();
  while (true) {
    final currentDateStr = _formatDate(currentDate);
    print('\nModifying Meal Data for: $currentDateStr');
    stdout.write('(n)ext day, (p)revious day, (o)kay to modify: ');
    final action = stdin.readLineSync()?.toLowerCase();

    if (action == 'n') {
      currentDate = currentDate.add(Duration(days: 1));
    } else if (action == 'p') {
      currentDate = currentDate.subtract(Duration(days: 1));
    } else if (action == 'o') {
      if (!data.containsKey(currentDateStr)) {
        print('No data found for $currentDateStr. Please enter data first.');
        return data;
      }

      print('\nWhich meal would you like to modify for $currentDateStr?');
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
      data[currentDateStr][mealKey] = newValue;
      return data; // Exit modify mode after modification
    } else {
      print('Invalid action. Use "n", "p", or "o".');
    }
  }
}