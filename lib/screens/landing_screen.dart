import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any material banners that might be showing from previous screens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A), // Deep Purple
              Color(0xFF8E24AA), // Purple
              Color(0xFFAB47BC), // Light Purple
              Color(0xFF9C27B0), // Medium Purple
              Color(0xFF7B1FA2), // Rich Purple
            ],
            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // Logo and Title
                        Text(
                          'Concord™',
                          style: GoogleFonts.orbitron(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        // Tagline
                        const Text(
                          'that social place you imagined',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'to meet and interact with new people',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Illustrations
                        AspectRatio(
                          aspectRatio: 0.9,
                          child: SvgPicture.asset(
                            'assets/illustrations/LoginLandingGraphic.svg',
                            fit: BoxFit.contain,
                            // Handle SVG filter and other advanced elements
                            allowDrawingOutsideViewBox: true,
                            placeholderBuilder: (BuildContext context) =>
                                Container(
                              height: 200,
                              width: 200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sign up button
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF000000),
                                Color(0xFFA20FC3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFCC0AE6),
                                offset: Offset(-2, -2),
                                blurRadius: 4,
                                spreadRadius: -1,
                              ),
                              BoxShadow(
                                color: Color(0xFFCC0AE6),
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.orbitron(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Log in button
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFE10BEC),
                                Color(0xFF5C0258),
                                Color(0xFFBD029A),
                              ],
                              transform: GradientRotation(120 *
                                  3.14159 /
                                  180), // 120 degrees in radians
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFCC0AE6),
                                offset: Offset(-2, -2),
                                blurRadius: 8,
                                spreadRadius: -1,
                              ),
                              BoxShadow(
                                color: Color(0xFFCC0AE6),
                                offset: Offset(2, 2),
                                blurRadius: 8,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Log in',
                              style: GoogleFonts.orbitron(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Copyright text
                        const Text(
                          '© 2025 Concord Studios',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
