import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

void main() {
  runApp(const MizrahanApp());
}

class MizrahanApp extends StatelessWidget {
  const MizrahanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מזרחן',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        fontFamily: 'Roboto', // Use a default system font that supports Hebrew
      ),
      home: const CompassScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final Uri _songUrl = Uri.parse('https://youtu.be/V-4W9fY2SkQ?si=RXYOOzm2jg8PJdE5');

  Future<void> _launchYouTube() async {
    if (!await launchUrl(_songUrl, mode: LaunchMode.inAppBrowserView)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מזרחן', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('בהכשרת רב', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Text('🎵', style: TextStyle(fontSize: 18)),
                onPressed: _launchYouTube,
                tooltip: 'כותל המזרח',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 20),
            // The red stationary needle pointing towards the dial center
            const Icon(Icons.arrow_drop_down, size: 60, color: Colors.red),
            Expanded(
              child: StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error reading compass: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final double? heading = snapshot.data?.heading;

                  if (heading == null) {
                    return const Center(child: Text('Device does not have compass sensors.'));
                  }

                  // The flutter_compass package returns a heading where North is 0, East is 90.
                  // We rotate the dial by -heading so North is normally at the top.
                  // When facing East (heading = 90), East (90 degrees on the dial) will rotate to the top.
                  final double angle = heading * (math.pi / 180) * -1;

                  return Center(
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 4),
                          color: Colors.amber.withAlpha(25), // 0.1 * 255
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 0 degrees = North
                            const _CompassLabel(label: 'צפון', angleDeg: 0, color: Colors.black, isMain: true),
                            // 45 degrees = North-East
                            const _CompassLabel(label: 'צפון-מזרח', angleDeg: 45, color: Colors.black, isMain: false),
                            // 90 degrees = East
                            const _CompassLabel(label: 'מזרח', angleDeg: 90, color: Colors.red, isMain: true),
                            // 135 degrees = South-East
                            const _CompassLabel(label: 'דרום-מזרח', angleDeg: 135, color: Colors.black, isMain: false),
                            // 180 degrees = South
                            const _CompassLabel(label: 'דרום', angleDeg: 180, color: Colors.black, isMain: true),
                            // 225 degrees = South-West
                            const _CompassLabel(label: 'דרום-מערב', angleDeg: 225, color: Colors.black, isMain: false),
                            // 270 degrees = West
                            const _CompassLabel(label: 'מערב', angleDeg: 270, color: Colors.black, isMain: true),
                            // 315 degrees = North-West
                            const _CompassLabel(label: 'צפון-מערב', angleDeg: 315, color: Colors.black, isMain: false),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _CompassLabel extends StatelessWidget {
  final String label;
  final double angleDeg;
  final Color color;
  final bool isMain;

  const _CompassLabel({
    required this.label,
    required this.angleDeg,
    required this.color,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    final double angleRad = angleDeg * (math.pi / 180);
    // The Container size is 350x350, meaning radius is 175.
    // We want the text to sit along the radius from center to edge.
    // A distance of roughly half the radius ensures it looks balanced.
    const double distance = 100;

    // Standard polar to cartesian coordinate mapping (adjusted for 12 o'clock North)
    final double adjustedAngleRad = angleRad - (math.pi / 2);

    final double x = distance * math.cos(adjustedAngleRad);
    final double y = distance * math.sin(adjustedAngleRad);

    return Transform.translate(
      offset: Offset(x, y),
      // Rotate the widget itself by (angle - 90 degrees) to run ALONG the radius.
      child: Transform.rotate(
        angle: adjustedAngleRad,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isMain ? 20 : 14,
                fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
            Icon(
              Icons.arrow_right, // When rotated, this points outward along the radius
              color: color,
              size: 32, // Triangles of exactly the same size
            ),
          ],
        ),
      ),
    );
  }
}
