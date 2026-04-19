import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPasswordHidden = true.obs; // Observable state

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
}
