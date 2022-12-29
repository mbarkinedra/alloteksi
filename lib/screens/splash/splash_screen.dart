import 'dart:async';
import 'package:alloteksi/constants/app_images.dart';
import 'package:alloteksi/screens/home/home_screen.dart';
import 'package:alloteksi/screens/start_screen/start_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);
  final List<Future> initialFutures;
  SplashScreen({this.initialFutures});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 4;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  _loadWidget() async {
    var beginAt = DateTime.now();
    var second = 0;
    Duration _duration;
    await Future.wait(widget.initialFutures, eagerError: true);
    second = DateTime.now().difference(beginAt).inSeconds;
    if (second > splashDelay) {
      _duration = Duration(milliseconds: 100);
    } else {
      _duration = Duration(seconds: splashDelay - second);
    }

    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => StartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: new ExactAssetImage(AppImages.splashImg),
          fit: BoxFit.fill,
        ),
      ),
      // child: Center(
      //   child: Image.asset(
      //     AppImages.splashImg,
      //     fit: BoxFit.contain,
      //   ),
      // )
    );
  }
}
