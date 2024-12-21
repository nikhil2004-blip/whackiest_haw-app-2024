import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class GuardMap extends StatefulWidget {
  @override
  _GuardMapState createState() => _GuardMapState();
}

class _GuardMapState extends State<GuardMap> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> maskedZones = {};

  // Define zones with relative positions and sizes (as percentages)
  final List<Zone> zones = [
    Zone(id: 'zone1', left: 0 / 2390, top: 0 / 1120, width: (250 + 160) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone2', left: 0 / 2390, top: 230 / 1120, width: (250 + 160) / 2390, height: (500 + 160) / 1120),
    Zone(id: 'zone3', left: 0 / 2390, top: 810 / 1120, width: (970 + 160) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone4', left: (80 + 970) / 2390, top: 810 / 1120, width: (130 + 160) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone5', left: (2390 - 970 - 160) / 2390, top: 810 / 1120, width: (970 + 160) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone6', left: (2390 - 250 - 160) / 2390, top: 230 / 1120, width: (250 + 160) / 2390, height: (500 + 160) / 1120),
    Zone(id: 'zone7', left: (2390 - 250 - 160) / 2390, top: 0 / 1120, width: (250 + 160) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone8', left: 1130 / 2390, top: 0 / 1120, width: (850 + 80) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone9', left: 330 / 2390, top: 0 / 1120, width: (850 + 80) / 2390, height: (150 + 160) / 1120),
    Zone(id: 'zone10', left: (80 + 970) / 2390, top: 230 / 1120, width: (130 + 160) / 2390, height: (500 + 160) / 1120),
    Zone(id: 'zone11', left: 330 / 2390, top: 230 / 1120, width: (640 + 160) / 2390, height: (500 + 160) / 1120),
    Zone(id: 'zone12', left: 1260 / 2390, top: 230 / 1120, width: (640 + 160) / 2390, height: (500 + 160) / 1120),
  ];

  @override
  void initState() {
    super.initState();
    _loadZoneData();
    _setupRealTimeUpdates();
  }

  // Load initial zone data from Firestore
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

  // Set up real-time updates
  void _setupRealTimeUpdates() {
    _firestore.collection('zones').snapshots().listen((snapshot) {
      setState(() {
        for (final doc in snapshot.docs) {
          maskedZones[doc.id] = doc['masked'] ?? false;
        }
      });
    });
  }

  // Update zone state in Firestore
  Future<void> _updateZoneState(String zoneId, bool masked) async {
    try {
      await _firestore.collection('zones').doc(zoneId).set({'masked': masked});
    } catch (e) {
      print('Error updating zone state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Image's original aspect ratio
        const double imageAspectRatio = 2390 / 1120;

        // Calculate the actual dimensions of the image
        final double containerWidth = constraints.maxWidth;
        final double containerHeight = constraints.maxHeight;
        double imageWidth, imageHeight;

        if (containerWidth / containerHeight > imageAspectRatio) {
          // Container is wider than the image's aspect ratio
          imageHeight = containerHeight;
          imageWidth = imageHeight * imageAspectRatio;
        } else {
          // Container is taller than the image's aspect ratio
          imageWidth = containerWidth;
          imageHeight = imageWidth / imageAspectRatio;
        }

        final double horizontalOffset = (containerWidth - imageWidth) / 2;
        final double verticalOffset = (containerHeight - imageHeight) / 2;

        return Stack(
          children: [
            // Display the map image
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
            // Overlay the masks directly on top of the image
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
                    });
                    _updateZoneState(zone.id, newState);

                    // Automatically reset the zone after 90 seconds
                    if (newState) {
                      Timer(Duration(seconds: 90), () {
                        setState(() {
                          maskedZones[zone.id] = false;
                        });
                        _updateZoneState(zone.id, false);
                      });
                    }
                  },
                  child: Container(
                    color: (maskedZones[zone.id] ?? false)
                        ? Colors.red.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
              ),
          ],
        );
      },
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
