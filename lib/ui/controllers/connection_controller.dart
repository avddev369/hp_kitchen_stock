import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConnectionManager extends GetxController {
  RxBool connectionType = true.obs;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> streamSubscription;

  @override
  void onInit() {
    super.onInit();
    getConnectionType();
    streamSubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      updateState(results);
    });
  }

  Future<void> getConnectionType() async {
    List<ConnectivityResult> connectivityResults;
    try {
      connectivityResults = await connectivity.checkConnectivity();
      updateState(connectivityResults);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void updateState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
      connectionType.value = true; // Connected
    } else if (results.contains(ConnectivityResult.none)) {
      connectionType.value = false; // No Connection
    } else {
      Get.snackbar('Network Error', 'Failed to get Network Status');
    }
  }

  @override
  void onClose() {
    streamSubscription.cancel();
    super.onClose();
  }
}
