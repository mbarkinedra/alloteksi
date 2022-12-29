import 'dart:async';
import 'dart:io';
import 'package:alloteksi/constants/app_colors.dart';
import 'package:alloteksi/constants/app_images.dart';
import 'package:alloteksi/models/request_permission.dart';
import 'package:alloteksi/screens/home/home_screen.dart';
import 'package:alloteksi/screens/numero_screen/numero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool hadPb = false;

  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onProgressChanged;

  String mode = "Mode client";
  bool valueMode = false;
  final _history = [];

  void reloadWidget() {
    flutterWebViewPlugin?.reload();
  }

  @override
  void initState() {
    super.initState();
    RequestPermissionManager.requestLocationPermission();

    RequestPermissionManager.gpsService(context);
    // reloadWidget();
    flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        print('Webview Destroyed');
        // Scaffold.of(context)
        //     .showSnackBar(const SnackBar(content: Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          print('onUrlChanged: $url');
          _history.add('onUrlChanged: $url');
        });
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        setState(() {
          print('onProgressChanged: $progress');
          _history.add('onProgressChanged: $progress');
        });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          print('onStateChanged: ${state.type} ${state.url}');
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          if (error.url != "https://demo.allo-wewa.xyz/favicon.ico")
            hadPb = true;
          print('onHttpError: ${error.code} ${error.url} ${error.url}');
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
    });
  }

  bool isConnected = true;
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');

        setState(() {
          isConnected = true;
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        isConnected = false;
      });
    }
    return isConnected;
  }

  Stream<bool> streamCheckConnection() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      bool isConnected = await checkConnection();
      yield isConnected;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<bool> httpErrorStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));

      yield true;
    }
  }

  String url = "https://demo.allo-wewa.xyz/";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          elevation: 0,
          // leading: Container(),
          leading: GestureDetector(
            child: Icon(Icons.home),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => StartScreen()));
            },
          ),
          centerTitle: true,
          backgroundColor: AppColors.appThemeColor,
          title: Row(
            children: [
              Image.asset(
                AppImages.appLogoPng,
                fit: BoxFit.contain,
                height: size.height / 25,
              ),
              SizedBox(
                width: 15,
              ),
              Image.asset(
                AppImages.imgAppbar,
                fit: BoxFit.contain,
                height: size.height / 25,
                width: size.width / 3,
              ),
              Container()
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  flutterWebViewPlugin
                      .reloadUrl("https://demo.allo-wewa.xyz/logout.php");
                },
                child: Icon(Icons.logout))
          ],
        ),
        body: StreamBuilder<bool>(
            stream: streamCheckConnection(),
            builder: (context, snapshot) {
              if (isConnected == true) {
                return Scaffold(
                  backgroundColor: AppColors.appThemeColor,
                  body: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text(
                                mode,
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff20408e)),
                              ))),
                          Expanded(
                              child: Align(
                            child: Switch(
                              value: valueMode,
                              onChanged: (bool value) {
                                setState(() {
                                  if (value == false) {
                                    valueMode = value;
                                    mode = "Mode client";
                                  } else {
                                    valueMode = value;
                                    mode = "Mode chauffeur";
                                  }
                                });
                              },
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Image.asset(
                        AppImages.imgAppbar,
                        fit: BoxFit.contain,
                        height: size.height / 25,
                        width: size.width / 1.5,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Image.asset(
                        AppImages.appLogoPng,
                        width: size.width / 1.5,
                      ),
                      Image.asset(
                        AppImages.imgAppbar,
                        fit: BoxFit.contain,
                        height: size.height / 25,
                        width: size.width / 2,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Se déplacer en sécurité",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 23),
                      ),
                      Expanded(
                          child: Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          onPressed: () {
                            if (valueMode) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          NumeroScreen()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HomeScreen(
                                            isDriver: false,
                                          )));
                            }
                          },
                          child: Container(
                            // margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                            height: 50,
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Commencer',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: new DecorationImage(
                      image: new ExactAssetImage(AppImages.pbReseauImg),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              }
            }));
  }
}
