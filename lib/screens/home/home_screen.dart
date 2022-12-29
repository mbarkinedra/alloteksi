import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alloteksi/constants/app_colors.dart';
import 'package:alloteksi/constants/app_images.dart';
import 'package:alloteksi/models/request_permission.dart';
import 'package:alloteksi/screens/start_screen/start_screen.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:vibrate/vibrate.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isDriver;
  // final Widget floatingActionButton;
  HomeScreen({
    Key key,
    this.isDriver,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final globalKey = GlobalKey<ScaffoldState>();
  bool hadPb = false;
  String numero = "";
  Timer timer;
  final box = GetStorage();

  AudioPlayer audioPlayer = AudioPlayer();

  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  Client client = Client();

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onProgressChanged;

  final _history = [];

  String url = "";

  void reloadWidget() {
    flutterWebViewPlugin?.reload();
  }

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/alarm/Car-Lock.mp3');
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
     switch (state) {
      case AppLifecycleState.resumed:
        print('app resumed');
        break;
      
      case AppLifecycleState.inactive:
        print('app inactive');
        break;
      
      case AppLifecycleState.paused:
        print('app paused');
        break;
    
      case AppLifecycleState.detached:
        print('app deatched');
        break;
    }
  }

  Future<void> requestNumber() async {
    String jsonToSend = '{"number": "${numero.replaceAll(" ", "")}"}';

    var response = await client
        .post(Uri.http('api.allo-teksi.com', 'sonne.php'), body: jsonToSend);

    if (int.parse(response.body) == 1) {

      print("Alert");
      final file =
          new File('${(await getTemporaryDirectory()).path}/Car-Lock.mp3');
      await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
      final result = await audioPlayer.play(file.path, isLocal: true);

      Future.delayed(Duration(seconds: 4),() {
        audioPlayer.stop();
      });

      bool canVibrate = await Vibrate.canVibrate;
      Iterable<Duration> pauses = [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 500),
      ];
      Vibrate.vibrateWithPauses(pauses);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isDriver) {
      url = "https://demo.allo-wewa.xyz/recevoir_code.php";
    } else {
      numero = box.read('numero');
      print(numero);
      url = "https://demo.allo-wewa.xyz/chauffeur4/index.php?Mnumero=$numero";
      timer = Timer.periodic(Duration(seconds: 15), (Timer t) => requestNumber());
    }
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
    audioPlayer.stop();
    timer.cancel();
    super.dispose();
  }

  Stream<bool> httpErrorStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));

      yield true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          // leading: Container(),

          leading: GestureDetector(
            child: Icon(Icons.home),
            onTap: () {
              print("AIE");
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => StartScreen()), 
                      ModalRoute.withName('/'));
            },
          ),
          centerTitle: true,
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
          backgroundColor: AppColors.appThemeColor,
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
                return WebviewScaffold(
                  url: url,
                  withZoom: true,
                  hidden: true,
                  geolocationEnabled: true,
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


// import 'dart:async';
// import 'package:alloteksi/constants/app_colors.dart';
// import 'package:alloteksi/constants/app_images.dart';
// import 'package:alloteksi/models/request_permission.dart';
// import 'package:alloteksi/screens/logout/logout.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final globalKey = GlobalKey<ScaffoldState>();
//   bool hadPb = false;

//   // Instance of WebView plugin
//   final flutterWebViewPlugin = FlutterWebviewPlugin();

//   // On destroy stream
//   StreamSubscription _onDestroy;

//   // On urlChanged stream
//   StreamSubscription<String> _onUrlChanged;

//   // On urlChanged stream
//   StreamSubscription<WebViewStateChanged> _onStateChanged;

//   StreamSubscription<WebViewHttpError> _onHttpError;

//   StreamSubscription<double> _onProgressChanged;

//   final _history = [];

//   void reloadWidget() {
//     flutterWebViewPlugin?.reload();
//   }

// //   final PermissionHandler permissionHandler = PermissionHandler();
// //   Map<PermissionGroup, PermissionStatus> permissions;

// //   Future<bool> _requestPermission(PermissionGroup permission) async {
// //     final PermissionHandler _permissionHandler = PermissionHandler();
// //     var result = await _permissionHandler.requestPermissions([permission]);
// //     if (result[permission] == PermissionStatus.granted) {
// //       return true;
// //     }
// //     return false;
// //   }

// // /*Checking if your App has been Given Permission*/
// //   Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
// //     var granted = await _requestPermission(PermissionGroup.location);
// //     if (granted != true) {
// //       requestLocationPermission();
// //     }
// //     debugPrint('requestContactsPermission $granted');
// //     return granted;
// //   }

// // /*Show dialog if GPS not enabled and open settings location*/
// //   Future _checkGps() async {
// //     if (!(await Geolocator().isLocationServiceEnabled())) {
// //       if (Theme.of(context).platform == TargetPlatform.android) {
// //         showDialog(
// //             context: context,
// //             builder: (BuildContext context) {
// //               return AlertDialog(
// //                 title: Text("Can't get gurrent location"),
// //                 content:
// //                     const Text('Please make sure you enable GPS and try again'),
// //                 actions: <Widget>[
// //                   FlatButton(
// //                       child: Text('Ok'),
// //                       onPressed: () {
// //                         final AndroidIntent intent = AndroidIntent(
// //                             action:
// //                                 'android.settings.LOCATION_SOURCE_SETTINGS');
// //                         intent.launch();
// //                         Navigator.of(context, rootNavigator: true).pop();
// //                         _gpsService();
// //                       })
// //                 ],
// //               );
// //             });
// //       }
// //     }
// //   }

// // /*Check if gps service is enabled or not*/
// //   Future _gpsService() async {
// //     if (!(await Geolocator().isLocationServiceEnabled())) {
// //       _checkGps();
// //       return null;
// //     } else
// //       return true;
// //   }

//   @override
//   void initState() {
//     super.initState();
//     RequestPermissionManager.requestLocationPermission();

//     RequestPermissionManager.gpsService(context);
//     // reloadWidget();
//     flutterWebViewPlugin.close();

//     // Add a listener to on destroy WebView, so you can make came actions.
//     _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
//       if (mounted) {
//         // Actions like show a info toast.
//         print('Webview Destroyed');
//         // Scaffold.of(context)
//         //     .showSnackBar(const SnackBar(content: Text('Webview Destroyed')));
//       }
//     });

//     // Add a listener to on url changed
//     _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
//       if (mounted) {
//         setState(() {
//           print('onUrlChanged: $url');
//           _history.add('onUrlChanged: $url');
//         });
//       }
//     });

//     _onProgressChanged =
//         flutterWebViewPlugin.onProgressChanged.listen((double progress) {
//       if (mounted) {
//         setState(() {
//           print('onProgressChanged: $progress');
//           _history.add('onProgressChanged: $progress');
//         });
//       }
//     });

//     _onStateChanged =
//         flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
//       if (mounted) {
//         setState(() {
//           print('onStateChanged: ${state.type} ${state.url}');
//           _history.add('onStateChanged: ${state.type} ${state.url}');
//         });
//       }
//     });

//     _onHttpError =
//         flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
//       if (mounted) {
//         setState(() {
//           if (error.url != "https://demo.allo-wewa.xyz/favicon.ico")
//             hadPb = true;
//           print('onHttpError: ${error.code} ${error.url} ${error.url}');
//           _history.add('onHttpError: ${error.code} ${error.url}');
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // Every listener should be canceled, the same should be done with this stream.
//     // _onDestroy.cancel();
//     // _onUrlChanged.cancel();
//     // _onStateChanged.cancel();
//     // _onHttpError.cancel();
//     // _onProgressChanged.cancel();
//     // flutterWebViewPlugin.dispose();

//     super.dispose();
//   }

//   Stream<bool> httpErrorStream() async* {
//     while (true) {
//       await Future.delayed(Duration(milliseconds: 500));

//       yield true;
//     }
//   }

//   String url = "https://demo.allo-wewa.xyz/";

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//         key: globalKey,
//         appBar: AppBar(
//           // leading: Container(),

//           leading: GestureDetector(
//             child: Icon(Icons.home),
//             onTap: () {
//               flutterWebViewPlugin.reloadUrl(url);
//             },
//           ),
//           centerTitle: true,
//           title: Row(
//             children: [
//               Image.asset(
//                 AppImages.appLogoPng,
//                 fit: BoxFit.contain,
//                 height: size.height / 25,
//               ),
//               SizedBox(
//                 width: 15,
//               ),
//               Image.asset(
//                 AppImages.imgAppbar,
//                 fit: BoxFit.contain,
//                 height: size.height / 25,
//                 width: size.width / 3,
//               ),
//               Container()
//             ],
//           ),
//           backgroundColor: AppColors.appThemeColor,
//           actions: <Widget>[
//             FlatButton(
//                 onPressed: () {
//                   flutterWebViewPlugin
//                       .reloadUrl("https://demo.allo-wewa.xyz/logout.php");

//                   // // flutterWebViewPlugin.close().then((value) => Navigator.push(
//                   // //     context,
//                   // //     MaterialPageRoute(
//                   // //         builder: (BuildContext context) => LogOut())));
//                   // flutterWebViewPlugin.dispose();
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //         builder: (BuildContext context) => LogOut()));
//                 },
//                 child: Icon(Icons.logout))
//           ],
//         ),
//         body: hadPb
//             ? Container(
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   image: new DecorationImage(
//                     image: new ExactAssetImage(AppImages.pbReseauImg),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               )
//             : WebviewScaffold(
//                 url: url,
//                 withZoom: true,
//                 hidden: true,
//                 geolocationEnabled: true,
//               ));
//   }
// }
