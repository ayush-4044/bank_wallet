import 'dart:async';
import 'package:bookyourev/admin/admin_dashboard.dart';
import 'package:bookyourev/agency/agency_dashboard.dart';
import 'package:bookyourev/onboardingscreen.dart';
import 'package:bookyourev/login_screen.dart';
import 'package:bookyourev/user/user_0dashboard.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    startTime();
    super.initState();
  }

  startTime() {
    var _duration = new Duration(seconds: 5);
    return new Timer(_duration, () {
      checkFirstSeen();
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      if (prefs.getString('uid') != null) {
        if (prefs.getString('urole') != null &&
            prefs.getString('urole') == "0") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => AdminDashboardPage()),
              (Route<dynamic> route) => false);
        } else if (prefs.getString('urole') != null &&
            prefs.getString('urole') == "1") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => UserDashboardPage()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => AgencyDashboard()),
              (Route<dynamic> route) => false);
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
            (Route<dynamic> route) => false);
      }
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => OnBoardingPage()),
          (Route<dynamic> route) => false);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Lottie.asset("assets/images/Splash.json"),
            ),
          ],
        ),
      ),
    );
  }
}
