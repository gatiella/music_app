import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../home/home_screen.dart';
import 'package:music_app/app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoRotation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main animation controller for entrance effects
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Rotation controller for logo spinning
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse controller for breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Wave controller for background animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Fade animation for overall opacity
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Scale animation for logo entrance
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Slide animation for text
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Logo rotation animation
    _logoRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Pulse animation for breathing effect
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for background
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  void _startAnimationSequence() {
    // Start main animation
    _mainController.forward();

    // Start continuous animations
    _waveController.repeat();
    _pulseController.repeat(reverse: true);

    // Start logo rotation after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _rotationController.forward();
      }
    });

    // Navigate to home screen
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);
                  var fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(CurvedAnimation(parent: animation, curve: curve));

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: fadeAnimation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Animated background gradient
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          MusicAppTheme.primaryGradient[0],
                          MusicAppTheme.primaryGradient[1],
                          _waveAnimation.value * 0.2,
                        )!,
                        Color.lerp(
                          MusicAppTheme.secondaryGradient[0],
                          MusicAppTheme.secondaryGradient[1],
                          _waveAnimation.value * 0.3,
                        )!,
                        Color.lerp(
                          MusicAppTheme.primaryGradient[1],
                          MusicAppTheme.primaryGradient[0],
                          _waveAnimation.value * 0.4,
                        )!,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Floating particles/orbs
            ...List.generate(6, (index) => _buildFloatingOrb(index, size)),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _mainController,
                  _rotationController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with glassmorphism effect
                        Transform.scale(
                          scale: _scaleAnimation.value * _pulseAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    // FIXED: Using proper opacity method
                                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    size: 70,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App title with slide animation
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              Text(
                                'SoundWave',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your music, amplified',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Custom loading indicator
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CustomPaint(
                            painter: LoadingPainter(_mainController.value),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingOrb(int index, Size size) {
    final random = math.Random(index);
    final orbSize = 20 + random.nextDouble() * 40;

    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        final offsetX =
            size.width * 0.2 +
            math.sin(_waveAnimation.value + index) * size.width * 0.6;
        final offsetY =
            size.height * 0.2 +
            math.cos(_waveAnimation.value * 0.7 + index) * size.height * 0.6;

        return Positioned(
          left: offsetX,
          top: offsetY,
          child: Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  // FIXED: Using proper opacity method
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                  Colors.transparent
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }
}

class LoadingPainter extends CustomPainter {
  final double progress;

  LoadingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2) // FIXED: Using proper opacity method
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}