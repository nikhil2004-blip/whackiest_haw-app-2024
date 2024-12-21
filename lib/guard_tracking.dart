import 'package:flutter/material.dart';

class GuardMap extends StatefulWidget {
  @override
  _GuardMapState createState() => _GuardMapState();
}

class _GuardMapState extends State<GuardMap> {
  final Map<String, bool> maskedZones = {};

  // Define zones with relative positions and sizes (as percentages)
  final List<Zone> zones = [
    Zone(id: 'zone1', left: 0 / 2390, top: 0 / 1120, width: (250+160) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone2', left: 0 / 2390, top: 230 / 1120, width: (250+160) / 2390, height: (500+160) / 1120),
    Zone(id: 'zone3', left: 0 / 2390, top: 810 / 1120, width: (970+160) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone4', left: (80+970) / 2390, top: 810 / 1120, width: (130+160) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone5', left: (2390-970-160) / 2390, top: 810 / 1120, width: (970+160) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone6', left: (2390-250-160) / 2390, top: 230 / 1120, width: (250+160) / 2390, height: (500+160) / 1120),
    Zone(id: 'zone7', left: (2390-250-160) / 2390, top: 0 / 1120, width: (250+160) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone8', left: 1130 / 2390, top: 0 / 1120, width: (850+80) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone9', left: 330 / 2390, top: 0 / 1120, width: (850+80) / 2390, height: (150+160) / 1120),
    Zone(id: 'zone10', left: (80+970) / 2390, top: 230 / 1120, width: (130+160) / 2390, height: (500+160) / 1120),
    Zone(id: 'zone11', left: 330 / 2390, top: 230 / 1120, width: (640+160) / 2390, height: (500+160) / 1120),
    Zone(id: 'zone12', left: 1260 / 2390, top: 230 / 1120, width: (640+160) / 2390, height: (500+160) / 1120),
  ];

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
                    setState(() {
                      maskedZones[zone.id] = !(maskedZones[zone.id] ?? false);
                    });
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
