import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:sih/Onboarding/Onboarding_view.dart';
import 'package:sih/page/demo_page.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  bool? isOldUser;

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  void checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOldUser = prefs.getBool("onboarding") ?? false;
    });
    print("Onboarding value: $isOldUser");
  }

  @override
  Widget build(BuildContext context) {
    if (isOldUser == null) {
      // Show a loading spinner while checking user status
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedSplashScreen(
      splash: ClipOval(
        child: Image.asset(
          'assets/splash.gif',
          width: 400,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
      splashIconSize: 400,
      splashTransition: SplashTransition.fadeTransition,
      centered: true,
      duration: 3100,
      nextScreen: isOldUser! ? const DemoPage() : const OnboardingView(),
    );
  }
}