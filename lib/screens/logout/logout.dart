import 'dart:async';

import 'package:alloteksi/constants/app_colors.dart';
import 'package:alloteksi/constants/app_images.dart';
import 'package:alloteksi/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class LogOut extends StatefulWidget {
  @override
  _LogOutState createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
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

  final _history = [];

  void reloadWidget() {
    flutterWebViewPlugin?.reload();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                flutterWebViewPlugin.dispose();
                // Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()));
              },
              child: Icon(Icons.arrow_back_ios)),
          centerTitle: true,
          title: Row(
            children: [
              Image.asset(
                AppImages.appLogoPng,
                fit: BoxFit.contain,
                height: 32,
              ),
              SizedBox(
                width: 15,
              ),
              Text('LogOut'),
              Container()
            ],
          ),
          backgroundColor: AppColors.appThemeColor,
        ),
        body: hadPb
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: new DecorationImage(
                    image: new ExactAssetImage(AppImages.pbReseauImg),
                    fit: BoxFit.fill,
                  ),
                ),
              )
            : WebviewScaffold(
                // url: "https://demo.allo-wewa.xyz/",
                url: "https://demo.allo-wewa.xyz/logout.php",
                withZoom: true,
                hidden: true,
                geolocationEnabled: true,
              ));
  }
}
