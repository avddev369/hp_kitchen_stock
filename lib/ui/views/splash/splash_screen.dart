import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFF0EA);
  static const Color kBackground = Color(0xFFF7F8FA);
  static const Color kBorder = Color(0xFFEEEFF4);
  static const Color kTextPrimary = Color(0xFF1A1D23);
  static const Color kTextSecondary = Color(0xFF9599B0);
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _sizeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
            CupertinoPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double logoScale = 0.82 + (_sizeAnimation.value * 0.18);

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF4EE), Color(0xFFF7F8FA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: -110,
                left: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kOrange.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -70,
                right: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kOrange.withOpacity(0.08),
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: logoScale,
                    child: Container(
                      width: 230,
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kOrangeLight,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Image.asset('assets/app_logo.png'),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Kitchen Stock',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your stock, movement, and history.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: kTextSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
