import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:klitchen_stock/api/api.dart';
import 'package:klitchen_stock/helper/preferences.dart';
import 'package:klitchen_stock/ui/controllers/global_binding.dart';
import 'package:klitchen_stock/ui/views/splash/splash_screen.dart';
import 'package:klitchen_stock/utils/app_color.dart';
import 'package:klitchen_stock/utils/size_config.dart';

import 'package:provider/provider.dart';

import 'itemProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configLoading();
  await Preferences.init();
  GlobalBindings().dependencies();
  // await Preferences.getToken();
  await Api.clientInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemProvider(),
      child: MyApp(),
    ),
  );}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..indicatorSize = 30.0
    ..radius = 8.0
    ..textColor = Colors.white
    ..backgroundColor = Color(0xff162F65)
    ..indicatorColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      SizeConfig().init(constraints, Orientation.portrait);

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: GlobalBindings(),
        title: 'Bvm Connect',
        theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorSchemeSeed: primaryColor,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(backgroundColor: Colors.transparent,shadowColor: Colors.transparent)
        ),
        builder: EasyLoading.init(),
        darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            brightness: Brightness.light,
            colorSchemeSeed: primaryColor,
            appBarTheme: AppBarTheme(backgroundColor: Colors.transparent,shadowColor: Colors.transparent)
        ),
        navigatorObservers: [PageLogObserver()],
        home:  SplashScreen(),
      );
    });
  }
}

class PageLogObserver extends NavigatorObserver {
  void _logCurrentPage(Route<dynamic>? route) {
    if (route == null) return;

    String pageName = route.settings.name ?? '';

    if (pageName.isEmpty && route is MaterialPageRoute) {
      final context = route.subtreeContext ?? navigator?.context ?? Get.context;
      if (context != null) {
        try {
          pageName = route.builder(context).runtimeType.toString();
        } catch (_) {
          pageName = route.runtimeType.toString();
        }
      }
    }

    if (pageName.isEmpty) {
      pageName = route.runtimeType.toString();
    }

    debugPrint('Current page: $pageName');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logCurrentPage(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logCurrentPage(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logCurrentPage(previousRoute);
  }
}
