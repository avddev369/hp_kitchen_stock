import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/views/auth/login.dart';

import '../../../helper/preferences.dart';
import '../homescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenAnimationState createState() => _SplashScreenAnimationState();
}

class _SplashScreenAnimationState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _sizeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _borderRadiusAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Check if the user is logged in or not
  void _checkLoginStatus() async {
    String? token = await Preferences.getToken();
    if (token != null) {
      String? userName = await Preferences.getUserName();
      // If the user is logged in, navigate to ShowItemsScreen
      Get.off(() => ShowItemsScreen(Username: userName ?? "N/A"));
    } else {
      // If the user is not logged in, navigate to LoginScreen
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double size = MediaQuery.of(context).size.width * _sizeAnimation.value;
          final double borderRadius = size * _borderRadiusAnimation.value;

          return Center(
            child: Container(
              width: _sizeAnimation.value < 1
                  ? size
                  : MediaQuery.of(context).size.width, // Full width for screen
              height: _sizeAnimation.value < 1
                  ? size
                  : MediaQuery.of(context).size.height, // Full height for screen
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: SvgPicture.asset('assets/logo5.svg'),
            ),
          );
        },
      ),
    );
  }
}
