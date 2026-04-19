import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CustomAlertDialog {
  // Function to show a simple error dialog with an icon and text
  static Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close the dialog after 1 second
          }
        });
        return AlertDialog(
          backgroundColor:
              Colors.white, // Transparent black background
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
             // SvgPicture.asset('assets/select.svg',height: 100,),
              SizedBox(
                //height:250,
               width: 300,
                child: Lottie.asset(
                  'assets/error.json', // Path to your Lottie file
                  fit: BoxFit.fitWidth,
                  repeat: true,
                ),
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.robotoCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog immediately if 'OK' is pressed
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show a success dialog with an icon and text
  static Future<void> showSuccessDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close the dialog after 1 second
          }
        });
        return AlertDialog(
          backgroundColor: Colors.white, // Dialog background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Animated success icon using Lottie
              SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset(
                  'assets/success.json', // Path to your Lottie file
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
              // Success message
              Text(
                message,
                style: GoogleFonts.robotoCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            // OK button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'OK',
                style: GoogleFonts.robotoCondensed(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // Function to show a selection dialog with an icon and text
  static Future<void> showSelectionDialog(
      BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        // Future.delayed(Duration(seconds: 1), () {
        //   if (Navigator.canPop(context)) {
        //     Navigator.of(context).pop(); // Close the dialog after 1 second
        //   }
        // });
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning_amber_outlined, // Warning icon
                color: Colors.yellow,
                size: 50,
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog immediately if 'OK' is pressed
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showLogoutDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        // Future.delayed(Duration(seconds: 1), () {
        //   if (Navigator.canPop(context)) {
        //     Navigator.of(context).pop(); // Close the dialog after 1 second
        //   }
        // });
        return AlertDialog(
          backgroundColor:
              Colors.white, // Transparent black background
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.lock, // Success icon
                color: Colors.black,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.robotoCondensed(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button background color
                    padding: EdgeInsets.all(8.0), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    elevation: 0, // Remove button's default elevation
                    minimumSize:
                        Size(80, 40), // Width and height for the button
                  ),
                  onPressed: () async {},
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
                SizedBox(width: 10.0), // Spacing between buttons
                // Cancel Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // Button background color
                    padding: EdgeInsets.all(8.0), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    elevation: 0, // Remove button's default elevation
                    minimumSize:
                        Size(80, 40), // Width and height for the button
                  ),
                  onPressed: () {
                    Get.back();
                    print("Cancel button pressed");
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Generic dialog with custom actions defined by the user
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon, // Optional icon
    Color? iconColor,
    double iconSize = 40.0,
    Color backgroundColor = Colors.white,
    EdgeInsets contentPadding = const EdgeInsets.all(16.0),
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    List<Widget>? actions, // Accept user-defined actions
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor, // Dialog background color
          contentPadding: contentPadding,
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? Colors.black, size: iconSize),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: titleStyle ??
                      GoogleFonts.robotoCondensed(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: contentStyle ??
                GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.black,
                ),
          ),
          actions: actions ??
              [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "OK",
                    style: GoogleFonts.robotoCondensed(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
        );
      },
    );
  }
}
