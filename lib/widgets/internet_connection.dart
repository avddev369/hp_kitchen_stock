import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/connection_controller.dart';
import 'package:klitchen_stock/ui/views/offline/no_Internet_screen.dart';


class CheckInternetConnection extends StatelessWidget {
  final Widget child;
  final bool isPushScreen;

  const CheckInternetConnection(
      {Key? key, required this.child, required this.isPushScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectionManager>(
      builder: (controller) =>
          Obx(() {
            if (controller.connectionType.value) {
              return child;
            }
            if(controller.connectionType.value == false && isPushScreen == true) {
              return SizedBox();
            }
            return NoInternetScreen();
          }),
    );
  }
}