import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF795ED9),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          
          children: [
            const PageHeader(
              backgroundColor: Color(0xFF795ED9),
              headerTitle: 'EduMate',
            ),
            AnimatedBuilder(
              animation: _controller,
              child: Container(
                height: 100.0,
                width: 100.0,
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 50,
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF795ED9),
                ),
              ),
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * math.pi,
                  child: child,
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              'Loading EduMate...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
