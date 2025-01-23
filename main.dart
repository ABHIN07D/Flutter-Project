import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterIntakeApp());
}

class WaterIntakeApp extends StatelessWidget {
  const WaterIntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Water Intake App",
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WaterIntakeHomepage(),
    );
  }
}

class WaterIntakeHomepage extends StatefulWidget {
  const WaterIntakeHomepage({super.key});

  @override
  State<WaterIntakeHomepage> createState() => _WaterIntakeHomepageState();
}

class _WaterIntakeHomepageState extends State<WaterIntakeHomepage> {
  int waterIntake = 0;
  int dailyGoal = 8;
  final List<int> dailyGoalOptions = [8, 10, 12];

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      waterIntake = prefs.getInt("WaterIntake") ?? 0;
      dailyGoal = prefs.getInt("DailyGoal") ?? 8;
    });
  }

  Future<void> incrementWaterIntake() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      waterIntake++;
      prefs.setInt("WaterIntake", waterIntake);
      if (waterIntake >= dailyGoal) {
        showGoalReachedAlert();
      }
    });
  }

  Future<void> resetWaterIntake() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      waterIntake = 0;
      prefs.setInt("WaterIntake", waterIntake);
    });
  }

  Future<void> setDailyGoal(int newGoal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyGoal = newGoal;
      prefs.setInt("DailyGoal", newGoal);
    });
  }

  Future<void> showGoalReachedAlert() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text(
            "You have reached your daily goal of $dailyGoal glasses of water!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showResetAlert() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Water Intake"),
          content: const Text("Are you sure you want to reset?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                resetWaterIntake();
                Navigator.of(context).pop();
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = dailyGoal > 0 ? waterIntake / dailyGoal : 0;
    bool goalReached = waterIntake >= dailyGoal;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Water Intake Analyzer",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, color: Colors.blue, size: 50),
              const SizedBox(height: 20),
              const Text("You have consumed"),
              Text(
                "$waterIntake glasses of water",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color.fromARGB(255, 137, 203, 234),
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                minHeight: 10,
              ),
              const SizedBox(height: 20),
              const Text("Daily Goal :"),
              DropdownButton<int>(
                elevation: 10,
                
                value: dailyGoal,
                items: dailyGoalOptions.map((int value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text("$value Glasses"),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) setDailyGoal(newValue);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: goalReached?null:incrementWaterIntake,
                child: const Text("Add Glass"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showResetAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 129, 216),
                ),
                child: const Text("Reset"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
