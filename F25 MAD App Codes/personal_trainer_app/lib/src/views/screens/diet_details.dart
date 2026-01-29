import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DietDetailsScreen extends StatefulWidget {
  // If no plan name is passed, we default to "Beginner"
  final String planName;

  const DietDetailsScreen({super.key, this.planName = "BEGINNER"});

  @override
  State<DietDetailsScreen> createState() => _DietDetailsScreenState();
}

class _DietDetailsScreenState extends State<DietDetailsScreen> {
  // --- STATE VARIABLES ---
  int _totalCalories = 0;
  int _consumedCalories = 0;

  // --- FAKE DATABASE OF DIET PLANS ---
  final Map<String, List<Map<String, dynamic>>> _dietData = {
    "BEGINNER": [
      {"time": "08:00 AM", "food": "Oatmeal with Berries", "cal": 300, "isEaten": false},
      {"time": "11:00 AM", "food": "Green Apple & Almonds", "cal": 150, "isEaten": false},
      {"time": "01:00 PM", "food": "Grilled Chicken Salad", "cal": 450, "isEaten": false},
      {"time": "05:00 PM", "food": "Greek Yogurt", "cal": 120, "isEaten": false},
      {"time": "08:00 PM", "food": "Steamed Veggies & Fish", "cal": 400, "isEaten": false},
    ],
    "INTERMEDIATE": [
      {"time": "07:30 AM", "food": "3 Egg Omelette", "cal": 400, "isEaten": false},
      {"time": "10:30 AM", "food": "Protein Shake", "cal": 180, "isEaten": false},
      {"time": "01:00 PM", "food": "Tuna Sandwich (Whole Wheat)", "cal": 500, "isEaten": false},
      {"time": "04:30 PM", "food": "Banana & Peanut Butter", "cal": 250, "isEaten": false},
      {"time": "08:00 PM", "food": "Lean Steak with Rice", "cal": 600, "isEaten": false},
    ],
    "ADVANCED": [
      {"time": "07:00 AM", "food": "Egg Whites & Avocado", "cal": 350, "isEaten": false},
      {"time": "10:00 AM", "food": "Chicken Breast & Rice", "cal": 500, "isEaten": false},
      {"time": "01:00 PM", "food": "Salmon & Sweet Potato", "cal": 550, "isEaten": false},
      {"time": "04:00 PM", "food": "Pre-Workout Carb Drink", "cal": 200, "isEaten": false},
      {"time": "07:00 PM", "food": "Casein Protein Bowl", "cal": 250, "isEaten": false},
    ],
  };

  List<Map<String, dynamic>> currentMeals = [];

  @override
  void initState() {
    super.initState();
    // 1. Load the correct list
    // This logic handles names like "BEGINNER: DETOX" by taking just the first word
    String key = widget.planName.toUpperCase().split(":")[0].split(" ")[0];

    // Default to beginner if key not found
    if (!_dietData.containsKey(key)) {
      key = "BEGINNER";
    }

    currentMeals = List.from(_dietData[key]!); // Create a copy so we can toggle checkboxes

    // 2. Calculate Total Calories for this plan
    for (var meal in currentMeals) {
      _totalCalories += (meal['cal'] as int);
    }
  }

  void _toggleMeal(int index, bool? value) {
    setState(() {
      currentMeals[index]['isEaten'] = value;
      // Recalculate consumed calories
      int cal = currentMeals[index]['cal'] as int;
      if (value == true) {
        _consumedCalories += cal;
      } else {
        _consumedCalories -= cal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset('assets/images/back_icon.png', fit: BoxFit.contain),
          ),
        ),
        title: Text(
          widget.planName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. CALORIE COUNTER CARD ---
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF64C8D6), // Cyan/Teal
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Calories Consumed", style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                          "$_consumedCalories / $_totalCalories",
                          style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "kcal",
                          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 16),
                        ),
                      ],
                    ),
                    // Progress Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator(
                            value: _totalCalories == 0 ? 0 : _consumedCalories / _totalCalories,
                            color: Colors.white,
                            backgroundColor: Colors.black12,
                            strokeWidth: 6,
                          ),
                        ),
                        // WARNING: Make sure this image name matches exactly!
                        // If it fails, try 'assets/images/nutrition_icon.png' (underscore instead of space)
                        Image.asset('assets/images/nutrition_icon.png', height: 30, width: 30,
                            errorBuilder: (c,o,s) => const Icon(Icons.local_dining, color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),

              // --- 2. MEAL LIST ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: currentMeals.length,
                  itemBuilder: (context, index) {
                    final meal = currentMeals[index];
                    final bool isEaten = meal['isEaten'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Fallback if image fails
                        image: const DecorationImage(
                          image: AssetImage('assets/images/grey_button.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        // Time
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meal['time'],
                            style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        // Food Name
                        title: Text(
                          meal['food'],
                          style: TextStyle(
                            color: isEaten ? Colors.green : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isEaten ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        // Calories
                        subtitle: Text(
                          "${meal['cal']} kcal",
                          style: TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                        // Checkbox
                        trailing: Checkbox(
                          value: isEaten,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => _toggleMeal(index, val),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- 3. FINISH BUTTON ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Diet Log Saved!"), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/button_gradient_bg.png'), // Use your gradient button
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'FINISH DAY',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}