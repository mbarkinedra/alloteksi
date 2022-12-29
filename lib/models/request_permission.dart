import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';

class RequestPermissionManager {
  static Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if your App has been Given Permission*/
  static Future<bool> requestLocationPermission(
      {Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.location);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }
    static Future<bool> requestCameraPermission(
      {Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.camera);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }

/*Show dialog if GPS not enabled and open settings location*/
  static Future _checkGps(BuildContext context) async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        gpsService(context);
                      })
                ],
              );
            });
      }
    }
  }

/*Check if gps service is enabled or not*/
  static Future gpsService(BuildContext context) async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      _checkGps(context);
      return null;
    } else
      return true;
  }
}
