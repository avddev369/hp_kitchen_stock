import 'package:flutter/material.dart';


class NoInternetScreen extends StatefulWidget {
  NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red, Colors.red],
            stops: [0.1, 0.6]),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No internet connection found.",
                style: TextStyle(

                    fontSize: 16,
                    letterSpacing: 1),
              ),
              // SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  print("No internet connection found.");
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 15),
                  child: Text(
                    "View offline downloads",
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1),
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