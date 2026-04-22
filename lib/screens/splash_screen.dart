import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

// WHY THIS FILE EXISTS:
// This is the first screen the user sees when they open the app.
// It runs for ~3.5 seconds with animations then navigates to HomeScreen.
// Design: Dark tech aesthetic with animated floating math particles,
// a glowing matrix grid, and staggered text reveals.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── ANIMATION CONTROLLERS ─────────────────────────────────

  // Controls the overall fade in of the whole screen
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // Controls the ITE114 text scale + fade
  late AnimationController _titleController;
  late Animation<double> _titleScaleAnim;
  late Animation<double> _titleFadeAnim;

  // Controls the description text slide up
  late AnimationController _descController;
  late Animation<Offset> _descSlideAnim;
  late Animation<double> _descFadeAnim;

  // Controls the developer credit fade in
  late AnimationController _devController;
  late Animation<double> _devFadeAnim;

  // Controls the glowing pulse on ITE114 text
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Controls the rotating matrix grid background
  late AnimationController _gridController;
  late Animation<double> _gridAnim;

  // Controls the floating particles
  late AnimationController _particleController;

  // Controls the bottom progress bar
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  // WHY: We generate random particles once so they
  // don't re-randomize on every rebuild
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Generate floating math symbol particles
    _particles = List.generate(18, (i) => _Particle.random(i));

    // ── SETUP ALL ANIMATION CONTROLLERS ─────────────────

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleScaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _descController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _descSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(parent: _descController, curve: Curves.easeOutCubic),
        );
    _descFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _descController, curve: Curves.easeIn));

    _devController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _devFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _devController, curve: Curves.easeIn));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _gridAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_gridController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // ── STAGGERED ANIMATION SEQUENCE ──────────────────────
    // WHY: Each element appears with a delay for a cinematic feel
    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // Step 1: Fade in background (0ms)
    _fadeController.forward();
    _progressController.forward();

    // Step 2: ITE114 bursts in (300ms delay)
    await Future.delayed(const Duration(milliseconds: 300));
    _titleController.forward();

    // Step 3: Description slides up (900ms delay)
    await Future.delayed(const Duration(milliseconds: 600));
    _descController.forward();

    // Step 4: Developer credit fades in (1400ms delay)
    await Future.delayed(const Duration(milliseconds: 500));
    _devController.forward();

    // Step 5: Navigate to HomeScreen after 3.5 seconds total
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, animation, __, child) {
            // WHY: Fade + scale transition into HomeScreen
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.05, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _devController.dispose();
    _pulseController.dispose();
    _gridController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0018),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── LAYER 1: Animated grid background ─────────
            AnimatedBuilder(
              animation: _gridAnim,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _GridPainter(_gridAnim.value),
              ),
            ),

            // ── LAYER 2: Floating math particles ──────────
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  _particles,
                  _particleController.value,
                ),
              ),
            ),

            // ── LAYER 3: Radial glow center ────────────────
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7B00FF).withOpacity(0.18),
                      const Color(0xFF7B00FF).withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── LAYER 4: Main content ──────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Top spacer
                  const Spacer(flex: 3),

                  // ── ITE114 TITLE ──────────────────────────
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleFadeAnim,
                      child: ScaleTransition(
                        scale: _titleScaleAnim,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) => Transform.scale(
                            scale: _pulseAnim.value,
                            child: _buildTitle(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── DESCRIPTION ───────────────────────────
                  SlideTransition(
                    position: _descSlideAnim,
                    child: FadeTransition(
                      opacity: _descFadeAnim,
                      child: _buildDescription(),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── DEVELOPER CREDIT ──────────────────────
                  FadeTransition(
                    opacity: _devFadeAnim,
                    child: _buildDeveloperCredit(),
                  ),

                  const SizedBox(height: 20),

                  // ── PROGRESS BAR ──────────────────────────
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => _buildProgressBar(size.width),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ITE114 TITLE WIDGET ─────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        // Glowing bracket decorations
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left bracket
            _buildBracket(isLeft: true),
            const SizedBox(width: 16),

            // ITE114 text with layered glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow layer
                Text(
                  'ITE114',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 12
                      ..color = const Color(0xFF7B00FF).withOpacity(0.3)
                      ..maskFilter = const MaskFilter.blur(
                        BlurStyle.normal,
                        16,
                      ),
                  ),
                ),
                // Middle glow layer
                Text(
                  'ITE114',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = const Color(0xFFBF5FFF).withOpacity(0.5)
                      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
                  ),
                ),
                // Main crisp text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFE0AAFF),
                      Color(0xFFBF5FFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'ITE114',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),
            // Right bracket
            _buildBracket(isLeft: false),
          ],
        ),

        const SizedBox(height: 6),

        // Thin divider line under ITE114
        Container(
          width: 220,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFF7B00FF),
                Color(0xFFBF5FFF),
                Color(0xFF7B00FF),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ── MATRIX BRACKET ──────────────────────────────────────
  Widget _buildBracket({required bool isLeft}) {
    return SizedBox(
      width: 16,
      height: 88,
      child: CustomPaint(
        painter: _BracketPainter(
          isLeft: isLeft,
          color: const Color(0xFF9B5FE3),
        ),
      ),
    );
  }

  // ── DESCRIPTION WIDGET ──────────────────────────────────
  Widget _buildDescription() {
    return Column(
      children: [
        // Course label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF7B00FF).withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF7B00FF).withOpacity(0.08),
          ),
          child: const Text(
            'COLLEGE OF ARTS AND SCIENCES',
            style: TextStyle(
              color: Color(0xFF9B5FE3),
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Main description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFD0A0FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'Numerical Linear Algebra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Ampersand accent
              const Text(
                '&',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7B00FF),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD0A0FF), Color(0xFF9B5FE3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'Matrix Theory',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // MSU label
        Text(
          'MSU-Tawi-Tawi College of Technology and Oceanography',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── DEVELOPER CREDIT WIDGET ─────────────────────────────
  Widget _buildDeveloperCredit() {
    return Column(
      children: [
        // Separator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(width: 10),
            Text(
              '✦',
              style: TextStyle(
                color: const Color(0xFF7B00FF).withOpacity(0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Developed by text
        Text(
          'DEVELOPED BY',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        // BytesBuilder.dev with glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow behind text
            Text(
              'BytesBuilder.dev',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 8
                  ..color = const Color(0xFF7B00FF).withOpacity(0.25)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
              ),
            ),
            // Main text with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFE0AAFF), Color(0xFF7B00FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'BytesBuilder.dev',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PROGRESS BAR WIDGET ─────────────────────────────────
  Widget _buildProgressBar(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          // Loading label
          Text(
            _progressAnim.value < 1.0 ? 'Loading...' : 'Ready!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Progress track
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnim.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B00FF), Color(0xFFBF5FFF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B00FF).withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTERS ──────────────────────────────────────────

// Animated grid background
class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    const spacing = 52.0;
    final offset = (progress * spacing) % spacing;

    // Vertical lines
    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      final opacity = 0.04 + 0.02 * sin(progress * 2 * pi + x * 0.01);
      paint.color = Color.fromRGBO(123, 0, 255, opacity.clamp(0.0, 1.0));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (
      double y = -spacing + offset;
      y < size.height + spacing;
      y += spacing
    ) {
      final opacity = 0.04 + 0.02 * sin(progress * 2 * pi + y * 0.01);
      paint.color = Color.fromRGBO(123, 0, 255, opacity.clamp(0.0, 1.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Corner accent dots at grid intersections
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (double x = offset; x < size.width; x += spacing) {
      for (double y = offset; y < size.height; y += spacing) {
        final dist = sqrt(
          pow(x - size.width / 2, 2) + pow(y - size.height / 2, 2),
        );
        final maxDist = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2));
        final proximity = 1.0 - (dist / maxDist);
        final opacity = 0.04 + proximity * 0.08;
        dotPaint.color = Color.fromRGBO(191, 95, 255, opacity.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.progress != progress;
}

// Floating math symbol particles
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress + p.timeOffset) % 1.0;

      // Particles float upward and drift sideways
      final x =
          (p.baseX * size.width +
                  sin(t * 2 * pi * p.driftFreq) * 30 * p.driftAmp)
              .clamp(0.0, size.width);
      final y = (p.baseY * size.height - t * size.height * 0.6).clamp(
        0.0,
        size.height,
      );

      // Fade in and out as particle rises
      double opacity;
      if (t < 0.15) {
        opacity = t / 0.15;
      } else if (t > 0.75) {
        opacity = (1.0 - t) / 0.25;
      } else {
        opacity = 1.0;
      }
      opacity = (opacity * p.baseOpacity).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final textPainter = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(
            fontSize: p.size,
            color: p.color.withOpacity(opacity),
            fontWeight: FontWeight.w300,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// Matrix bracket painter
class _BracketPainter extends CustomPainter {
  final bool isLeft;
  final Color color;

  _BracketPainter({required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();

    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(2, 0);
      path.lineTo(2, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - 2, 0);
      path.lineTo(size.width - 2, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}

// ── PARTICLE DATA MODEL ──────────────────────────────────────
class _Particle {
  final String symbol;
  final double baseX;
  final double baseY;
  final double size;
  final double timeOffset;
  final double baseOpacity;
  final double driftFreq;
  final double driftAmp;
  final Color color;

  _Particle({
    required this.symbol,
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.timeOffset,
    required this.baseOpacity,
    required this.driftFreq,
    required this.driftAmp,
    required this.color,
  });

  static final _symbols = [
    'λ',
    'Σ',
    'π',
    'α',
    '∇',
    'Δ',
    '∈',
    '⊗',
    '1',
    '0',
    'n',
    'x',
    'A',
    'B',
    '∞',
    '∂',
    'μ',
    'β',
  ];

  static final _colors = [
    const Color(0xFF7B00FF),
    const Color(0xFF9B5FE3),
    const Color(0xFFBF5FFF),
    const Color(0xFFE0AAFF),
    const Color(0xFF5500BB),
  ];

  static _Particle random(int seed) {
    final rng = Random(seed * 1337 + 42);
    return _Particle(
      symbol: _symbols[rng.nextInt(_symbols.length)],
      baseX: rng.nextDouble(),
      baseY: 0.3 + rng.nextDouble() * 0.9,
      size: 12.0 + rng.nextDouble() * 18.0,
      timeOffset: rng.nextDouble(),
      baseOpacity: 0.15 + rng.nextDouble() * 0.35,
      driftFreq: 0.5 + rng.nextDouble() * 1.5,
      driftAmp: 0.3 + rng.nextDouble() * 0.7,
      color: _colors[rng.nextInt(_colors.length)],
    );
  }
}
