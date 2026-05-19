import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:klitchen_stock/helper/preferences.dart';
import '../../../api/api.dart';
import '../../controllers/logincontroller.dart';
import '../homescreen.dart';

class LoginScreen extends StatefulWidget {
  final String? imagePath;
  final Color? backgroundColor;

  LoginScreen({Key? key, this.imagePath, this.backgroundColor})
    : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFF0EA);
  static const Color kBackground = Color(0xFFF7F8FA);
  static const Color kTextPrimary = Color(0xFF1A1D23);
  static const Color kTextSecondary = Color(0xFF9599B0);
  static const Color kBorder = Color(0xFFEEEFF4);
  final LoginController loginController = Get.put(LoginController());
  File? _selectedImage;
  String? _cachedImagePath;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    String? token = await Preferences.getToken();
    if (token != null) {
      String? userName = await Preferences.getUserName();
      Get.off(() => ShowItemsScreen(Username: userName ?? "N/A"));
    }
  }

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Username and password cannot be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var response = await Api.login(
        _usernameController.text,
        _passwordController.text,
        context,
      );

      if (response != null && response['success'] == true) {
        String token = response['data']['token'] ?? '';
        String userName = response['data']['name'] ?? 'Unknown';

        await Preferences.saveToken(token);
        await Preferences.saveUserName(userName);

        Get.offAll(() => ShowItemsScreen(Username: userName));
      } else {
        _showErrorDialog(response?['msg'] ?? 'Unknown error');
      }
    } catch (error) {
      _showErrorDialog("Login failed: ${error.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: GoogleFonts.poppins(color: Colors.red)),
          content: Text(error, style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
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
            top: 80,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kOrange.withOpacity(0.10),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 82,
                            height: 82,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kOrangeLight,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child:
                                SvgPicture.asset(
                                  'assets/logo5.svg',
                                  fit: BoxFit.contain,
                                ).animate().scale().fadeIn(
                                  duration: const Duration(milliseconds: 500),
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2),
                        const SizedBox(height: 6),
                        Text(
                          'Login to continue managing your kitchen stock.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: kTextSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: _usernameController,
                          label: 'Phone Number or Username',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOrange,
                              disabledBackgroundColor: kOrange.withOpacity(
                                0.55,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  )
                                : Text(
                                    'LOG IN',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText ? _obscurePassword : false,
      style: GoogleFonts.poppins(fontSize: 14, color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: kTextSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: kTextSecondary),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: kTextSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFFFFBF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kOrange, width: 1.4),
        ),
      ),
    );
  }
}
