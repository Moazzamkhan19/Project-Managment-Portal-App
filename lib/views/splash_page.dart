import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with  SingleTickerProviderStateMixin{
  late AnimationController _textController;
  late Animation<Offset> _textoffsetAnimation;
  @override
  void initState() {
    super.initState();

    _textController = AnimationController(vsync: this,duration: const Duration(milliseconds: 800),);
    _textoffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),     // start from far left
      end: Offset.zero, // end at center
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut,));

    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });


    Timer(const Duration(seconds: 4), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/Lottie/settingsloadericon.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              delegates: LottieDelegates(
                values: [
                  // Apply color to all layers of the Lottie animation
                  ValueDelegate.color(
                    const ['**'], // targets all layers
                    value: Theme.of(context).primaryColor, // use your desired color
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _textoffsetAnimation,
              child: Text(
                "Project Management Portal",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }
}


