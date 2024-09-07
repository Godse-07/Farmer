import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sih/Onboarding/Onboarding_view.dart';
import 'package:sih/page/demo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Fetch the onboarding value, fallback to false if null
  final onboarding = prefs.getBool("onboarding") ?? false;

  // Debug print to verify the value
  print("Onboarding value: $onboarding");

  // Clear SharedPreferences if needed for debugging purposes
  // await prefs.clear();

  runApp(MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Conditional navigation based on the onboarding value
      home: onboarding ? const DemoPage() : const OnboardingView(),
    );
  }
}
