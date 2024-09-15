import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'second_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();

  void checkAuth(BuildContext context) async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
        bool result = await auth.authenticate(
          localizedReason: 'Please authenticate to proceed',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (result) {
          _proceedToNextScreen();
        } else {
          _showMessage(context, "Biometric authentication failed");
          _showAlternativeAuthOptions();
        }
      } else {
        _showMessage(context, "Biometric authentication is not available");
        _showAlternativeAuthOptions();
      }
    } catch (e) {
      _showMessage(context, "Error: ${e.toString()}");
      _showAlternativeAuthOptions();
    }
  }

  void _showAlternativeAuthOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Authentication Method"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _showPinDialog(),
                child: const Text("Enter PIN"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showPasswordDialog(),
                child: const Text("Enter Password"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter PIN"),
          content: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Enter 4-digit PIN"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_pinController.text == "1234") {
                  // Replace with actual PIN logic
                  _proceedToNextScreen();
                } else {
                  _showMessage(context, "Invalid PIN");
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: "Enter password"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement actual password checking logic here
                _showMessage(
                    context, "Password authentication not implemented");
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _proceedToNextScreen() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 220, // Increased height
                width: 220, // Increased width
                child: CircleAvatar(
                  radius: 150, // Increased radius
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    // Added ClipOval to ensure circular clipping
                    child: Image.asset(
                      'assets/FarmGuard.jpg',
                      width:
                          190, // Slightly smaller than the CircleAvatar for padding
                      height: 190,
                      fit: BoxFit
                          .cover, // Ensures the image covers the area without distortion
                    ),
                  ),
                ),
              ),
              const Text(
                "Welcome to FarmGuard",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 45),
              const Text(
                "Your one-stop solution for \n all your farming needs",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 45),
              Lottie.asset('assets/animation.json',
                  height: 180, width: 180, fit: BoxFit.fill),
              const SizedBox(height: 45),
              const Text(
                "Authenticate yourself to continue",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 45),
              ElevatedButton(
                onPressed: () => checkAuth(context),
                child: const Text(
                  "Authenticate",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
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
