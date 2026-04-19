import 'dart:io';
import 'package:flutter/cupertino.dart';
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

  LoginScreen({Key? key, this.imagePath, this.backgroundColor}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());

  Color bgColor = Colors.orange;
  Color shapeColor = Colors.orange;
  Color buttonColor = Colors.orange;
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
      var response = await Api.login(_usernameController.text, _passwordController.text, context);

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
      backgroundColor: Colors.orange,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/logo5.svg',
                    height: 130,
                    fit: BoxFit.contain,
                  ).animate().scale().fadeIn(duration: Duration(milliseconds: 500)),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 150),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Login',
                            style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 1000.ms).slideY(),
                          SizedBox(height: 20),
                          _buildInputField(controller: _usernameController, label: 'User Name or E-mail', icon: Icons.person_outline),
                          SizedBox(height: 15),
                          _buildInputField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading ? SpinKitFadingCircle(color: Colors.orange) : Text('LOG IN', style: TextStyle(fontSize: 16, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              minimumSize: Size(double.infinity, 50), // Set width to full width and height to 50
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: obscureText
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
