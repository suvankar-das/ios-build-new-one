import 'package:flutter/material.dart';
import 'package:native_in_flutter/view/main_tab/main_tab_bar_view.dart';
import 'package:native_in_flutter/api/api.dart';
import 'package:native_in_flutter/models/Settings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainScreen();
  }

  Future<void> _navigateToMainScreen() async {
    try {
      List<Settings> settings = await Api().fetchSettingsAndMovies();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainTabBarView(settings: settings),
        ),
      );
    } catch (error) {
      // Handle error appropriately here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/lottie/logoanimation.gif",
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset("assets/lottie/logoanimation.gif"),
          ),
        ],
      ),
    );
  }
}
