import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Import for orientation lock
import 'dart:async';

class GuardMap extends StatefulWidget {
  @override
  _GuardMapState createState() => _GuardMapState();
}

class _GuardMapState extends State<GuardMap> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> maskedZones = {};
  final Map<String, String> guardLabels = {}; // Stores labels for masked zones
  int guardCounter = 1; // Counter for assigning guard numbers

  final List<Zone> zones = [
    Zone(id: 'zone1', left: 0 / 2390, top: 0 / 3816, width: (250 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone2', left: 0 / 2390, top: 230 / 3816, width: (250 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone3', left: 0 / 2390, top: 810 / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone4', left: (80 + 970) / 2390, top: 810 / 3816, width: (130 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone5', left: (2390 - 970 - 160) / 2390, top: 810 / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone6', left: (2390 - 250 - 160) / 2390, top: 230 / 3816, width: (250 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone7', left: (2390 - 250 - 160) / 2390, top: 0 / 3816, width: (250 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone8', left: 1130 / 2390, top: 0 / 3816, width: (850 + 80) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone9', left: 330 / 2390, top: 0 / 3816, width: (850 + 80) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone10', left: (80 + 970) / 2390, top: 230 / 3816, width: (130 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone11', left: 330 / 2390, top: 230 / 3816, width: (640 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone12', left: 1260 / 2390, top: 230 / 3816, width: (640 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone13', left: 0 / 2390, top: 1348 / 3816, width: (250 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone14', left: 0 / 2390, top: (230+1348) / 3816, width: (250 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone15', left: 0 / 2390, top: (810+1348) / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone16', left: (80 + 970) / 2390, top: (810+1348) / 3816, width: (130 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone17', left: (2390 - 970 - 160) / 2390, top: (810+1348) / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone18', left: (2390 - 250 - 160) / 2390, top: (230+1348) / 3816, width: (250 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone19', left: 1010 / 2390, top: 1348 / 3816, width: (970 + 80) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone20', left: 330 / 2390, top: 1348 / 3816, width: (720 + 80) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone21', left: (80 + 970) / 2390, top: (230+1348) / 3816, width: (130 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone22', left: 330 / 2390, top: (230+1348) / 3816, width: (640 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone23', left: 1260 / 2390, top: (230+1348) / 3816, width: (640 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone24', left: 0 / 2390, top: (810+2696) / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone25', left: (80 + 970) / 2390, top: (810+2696) / 3816, width: (130 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone26', left: (2390 - 970 - 160) / 2390, top: (810+2696) / 3816, width: (970 + 160) / 2390, height: (150 + 160) / 3816),
    Zone(id: 'zone27', left: (2390 - 250 - 160) / 2390, top: (230+2696) / 3816, width: (250 + 160) / 2390, height: (500 + 160) / 3816),
    Zone(id: 'zone28', left: (80 + 970 - 190) / 2390, top: (230+2696+420) / 3816, width: (130 + 160 + 380) / 2390, height: (80 + 160) / 3816),
  ];

  @override
  void initState() {
    super.initState();
    _lockOrientation();
    _loadZoneData();
    _setupRealTimeUpdates();
  }

  @override
  void dispose() {
    _unlockOrientation();
    super.dispose();
  }

  Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<void> _unlockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _loadZoneData() async {
    try {
      final snapshot = await _firestore.collection('zones').get();
      setState(() {
        for (final doc in snapshot.docs) {
          maskedZones[doc.id] = doc['masked'] ?? false;
        }
      });
    } catch (e) {
      print('Error loading zones: $e');
    }
  }

  void _setupRealTimeUpdates() {
    _firestore.collection('zones').snapshots().listen((snapshot) {
      setState(() {
        for (final doc in snapshot.docs) {
          maskedZones[doc.id] = doc['masked'] ?? false;
        }
      });
    });
  }

  Future<void> _updateZoneState(String zoneId, bool masked) async {
    try {
      await _firestore.collection('zones').doc(zoneId).set({'masked': masked});
    } catch (e) {
      print('Error updating zone state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double imageAspectRatio = 2390 / 1120;
          final double containerWidth = constraints.maxWidth;
          final double containerHeight = constraints.maxHeight;
          double imageWidth, imageHeight;

          if (containerWidth / containerHeight > imageAspectRatio) {
            imageHeight = containerHeight;
            imageWidth = imageHeight * imageAspectRatio;
          } else {
            imageWidth = containerWidth;
            imageHeight = imageWidth / imageAspectRatio;
          }

          final double horizontalOffset = (containerWidth - imageWidth) / 2;
          final double verticalOffset = (containerHeight - imageHeight) / 2;

          return Stack(
            children: [
              Positioned(
                left: horizontalOffset,
                top: verticalOffset,
                width: imageWidth,
                height: imageHeight,
                child: Image.asset(
                  'assets/guard_map.png',
                  fit: BoxFit.fill,
                ),
              ),
              for (final zone in zones)
                Positioned(
                  left: horizontalOffset + zone.left * imageWidth,
                  top: verticalOffset + zone.top * imageHeight,
                  width: zone.width * imageWidth,
                  height: zone.height * imageHeight,
                  child: GestureDetector(
                    onTap: () {
                      final newState = !(maskedZones[zone.id] ?? false);
                      setState(() {
                        maskedZones[zone.id] = newState;
                        if (newState) {
                          guardLabels[zone.id] = '';
                        } else {
                          guardLabels.remove(zone.id);
                        }
                      });
                      _updateZoneState(zone.id, newState);

                      if (newState) {
                        Timer(Duration(seconds: 90), () {
                          setState(() {
                            maskedZones[zone.id] = false;
                            guardLabels.remove(zone.id);
                          });
                          _updateZoneState(zone.id, false);
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: (maskedZones[zone.id] ?? false)
                                ? Colors.red.withOpacity(0.5)
                                : Colors.transparent,
                            border: Border.all(
                              color: (maskedZones[zone.id] ?? false)
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        if (guardLabels.containsKey(zone.id))
                          Text(
                            guardLabels[zone.id]!,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class Zone {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  Zone({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

