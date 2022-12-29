import 'package:alloteksi/constants/app_colors.dart';
import 'package:alloteksi/models/preferences.dart';
import 'package:alloteksi/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.appThemeColor,
      statusBarColor: AppColors.appThemeColor));
  WidgetsFlutterBinding.ensureInitialized();
  await Wakelock.toggle(enable: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allo-Teksi',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   backgroundColor: AppColors.appThemeColor,
      //   primarySwatch: AppColors.appThemeColor,
      //   // visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: SplashScreen(
        initialFutures: [
          SharedPrefs.init(),
        ],
      ),
    );
  }
}
