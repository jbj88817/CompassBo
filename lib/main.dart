import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (context) {
          if (_hasPermission) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error reading heading: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          double? direction = snapshot.data!.heading;
          if (direction == null) {
            return const Center(
              child: Text('Device does not have sensors'),
            );
          }

          return Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Transform.rotate(
                angle: direction * (math.pi / 180) * -1,
                child: Image.asset(
                  'images/compass.jpeg',
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: Text('Request Permission'),
        onPressed: () {
          Permission.locationWhenInUse
              .request()
              .then((value) => _fetchPermissionStatus());
        },
      ),
    );
  }
}
