import 'package:flutter/cupertino.dart';
import 'package:klitchen_stock/utils/size_config.dart';


import '../utils/app_images.dart';

class AuthBackground extends StatefulWidget {
  Widget child;

  AuthBackground({super.key, required this.child});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 0,right: 0,child: Image.asset(up,width: SizeConfig.widthMultiplier! * 100,),),
        widget.child,
        Positioned(left: 0,bottom: 0,child: Image.asset(bottom,width: SizeConfig.widthMultiplier! * 80,),),
      ],
    );
  }
}
