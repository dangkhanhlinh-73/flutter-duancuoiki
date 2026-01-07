import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              user == null ? const LoginPage() : const HomePage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0000), Color(0xFF000000), Color(0xFF001122)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.movie_filter_outlined,
                  size: 100,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'MovieX',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade400,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.orange.withOpacity(0.8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Khám Phá Thế Giới Phim Ảnh',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 60),
              CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation(Colors.orange.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
