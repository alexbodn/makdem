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
  final Uri _songUrl = Uri.parse('https://www.youtube.com/watch?v=kYI13_fS1S4'); // Placeholder

  Future<void> _launchYouTube() async {
    if (!await launchUrl(_songUrl, mode: LaunchMode.externalApplication)) {
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Text('בהכשרת רב', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 50),
            // The red stationary needle pointing "East" (Up)
            const Icon(Icons.arrow_drop_up, size: 80, color: Colors.red),
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
                  // If we want North to be at the top, we rotate the dial by -heading.
                  // However, we want EAST to be at the top.
                  // Since East is normally 90 degrees clockwise from North,
                  // we rotate the dial by -heading and subtract another 90 degrees.
                  // Rotation angle: -heading - 90 degrees
                  final double angle = (heading * (math.pi / 180) * -1) - (math.pi / 2);

                  return Center(
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 4),
                          color: Colors.amber.withAlpha(25), // 0.1 * 255
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 0 degrees = North
                            const _CompassLabel(label: 'צפון', angleDeg: 0, color: Colors.black),
                            // 45 degrees = North-East
                            const _CompassLabel(label: 'צפון-מזרח', angleDeg: 45, color: Colors.black),
                            // 90 degrees = East
                            _CompassLabelWithButton(
                              label: 'מזרח',
                              angleDeg: 90,
                              color: Colors.red,
                              onPressed: _launchYouTube,
                            ),
                            // 135 degrees = South-East
                            const _CompassLabel(label: 'דרום-מזרח', angleDeg: 135, color: Colors.black),
                            // 180 degrees = South
                            const _CompassLabel(label: 'דרום', angleDeg: 180, color: Colors.black),
                            // 225 degrees = South-West
                            const _CompassLabel(label: 'דרום-מערב', angleDeg: 225, color: Colors.black),
                            // 270 degrees = West
                            const _CompassLabel(label: 'מערב', angleDeg: 270, color: Colors.black),
                            // 315 degrees = North-West
                            const _CompassLabel(label: 'צפון-מערב', angleDeg: 315, color: Colors.black),
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

  const _CompassLabel({
    required this.label,
    required this.angleDeg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double angleRad = angleDeg * (math.pi / 180);
    // Position text around the edge of the 300x300 circle (radius 150)
    // We adjust the radius to leave room for the text
    const double radius = 120;

    // Calculate x and y using standard trigonometry.
    // In Flutter, 0 is at 3 o'clock. In typical compass dial, 0 is at 12 o'clock.
    // So we subtract pi/2 from the angle.
    final double adjustedAngleRad = angleRad - (math.pi / 2);

    final double x = radius * math.cos(adjustedAngleRad);
    final double y = radius * math.sin(adjustedAngleRad);

    return Transform.translate(
      offset: Offset(x, y),
      // Rotate the text itself so it reads upright relative to the center
      child: Transform.rotate(
        angle: angleRad,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CompassLabelWithButton extends StatelessWidget {
  final String label;
  final double angleDeg;
  final Color color;
  final VoidCallback onPressed;

  const _CompassLabelWithButton({
    required this.label,
    required this.angleDeg,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double angleRad = angleDeg * (math.pi / 180);
    const double radius = 120;

    final double adjustedAngleRad = angleRad - (math.pi / 2);

    final double x = radius * math.cos(adjustedAngleRad);
    final double y = radius * math.sin(adjustedAngleRad);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: angleRad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            IconButton(
              icon: const Text('🎵', style: TextStyle(fontSize: 20)),
              onPressed: onPressed,
              tooltip: 'כותל המזרח',
            ),
          ],
        ),
      ),
    );
  }
}
