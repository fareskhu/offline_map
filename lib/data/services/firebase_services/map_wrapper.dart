import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:palmear_application/presentation/screens/map_screen.dart';
import 'package:palmear_application/presentation/screens/map_screen_mapbox.dart';

class MapWrapper extends StatefulWidget {
  const MapWrapper({super.key});

  @override
  State<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends State<MapWrapper> {
  bool hasInternet = true;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            hasInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            hasInternet = false;
          });
          break;
        default:
          setState(() {
            hasInternet = false;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet ? const MapScreen() : const MapScreenMapbox();
  }
}
