import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // delay tetap 3 detik biar splash-mu tetap muncul enak
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

    if (hasOnboarded) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            const Center(
              child: Text(
                'DRIVE ON',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplaySC',
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: -80,
              child: Image.asset(
                'assets/images/car_intro.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
