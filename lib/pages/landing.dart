import 'package:flutter/material.dart';
import 'customizations.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
  with TickerProviderStateMixin {
  late final AnimationController _finController;
  late final Animation<double> _finFloat;
  late final AnimationController _beltController;
  late final Animation<double> _beltOneFloat;
  late final Animation<double> _beltTwoFloat;
  late final Animation<double> _beltThreeFloat;
  late final AnimationController _introController;
  late final Animation<double> _beltOneIntro;
  late final Animation<double> _beltTwoIntro;
  late final Animation<double> _beltThreeIntro;
  bool _isButtonHovered = false;

  @override
  void initState() {
    super.initState();
    _finController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    )..repeat(reverse: true);
    _finFloat = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _finController, curve: Curves.easeInOut),
    );
    _beltController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _beltOneFloat = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _beltController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _beltTwoFloat = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(
        parent: _beltController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
      ),
    );
    _beltThreeFloat = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _beltController,
        curve: const Interval(0.05, 0.95, curve: Curves.easeInOut),
      ),
    );
    _introController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _beltOneIntro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _beltTwoIntro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 0.85, curve: Curves.easeOut),
    );
    _beltThreeIntro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _finController.dispose();
    _beltController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _startApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomizationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/denim/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/denim/jean_scrap.png',
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 40.0),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 65),
                            Text(
                              'Welcome to',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: isSmallScreen ? 20 : 30,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(1, 4),
                                    blurRadius: 0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'FINS!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Cartoon',
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontSize: isSmallScreen ? 65 : 75,
                                    height: 0.5,
                                    fontWeight: FontWeight.bold,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1, 8),
                                        blurRadius: 0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                AnimatedBuilder(
                                  animation: _finController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _finFloat.value),
                                      child: child,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Image.asset(
                                      'assets/images/finny.png',
                                      height: isSmallScreen ? 65 : 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      // Belt 1
                      AnimatedBuilder(
                        animation: _beltOneIntro,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 2,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                AnimatedBuilder(
                                  animation: _beltOneFloat,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        isSmallScreen ? -60 : -80,
                                        _beltOneFloat.value,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/denim/belt.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(isSmallScreen ? 200 : 220, 10, 16, 12),
                                  child: Text(
                                    'take charge of your\nfinances with ease.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final progress = _beltOneIntro.value;
                          return Opacity(
                            opacity: progress,
                            child: Transform.translate(
                              offset: Offset(0, (1 - progress) * 18),
                              child: child,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 30),

                      // Belt 2
                      AnimatedBuilder(
                        animation: _beltTwoIntro,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 2,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  AnimatedBuilder(
                                    animation: _beltTwoFloat,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          isSmallScreen ? -250 : -280,
                                          _beltTwoFloat.value,
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/images/denim/belt.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(isSmallScreen ? 10 : 10, 10, 340, 12),
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                                      child: Text(
                                        'track your goals in\none simple dashboard.',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final progress = _beltTwoIntro.value;
                          return Opacity(
                            opacity: progress,
                            child: Transform.translate(
                              offset: Offset(0, (1 - progress) * 18),
                              child: child,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 30),
                      
                      // Belt 3
                      AnimatedBuilder(
                        animation: _beltThreeIntro,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 2,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                AnimatedBuilder(
                                  animation: _beltThreeFloat,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        isSmallScreen ? 20 : 30,
                                        _beltThreeFloat.value,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/denim/belt.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(isSmallScreen ? 200 : 220, 10, 100, 12),
                                  child: Text(
                                    'stay organized and make\nsmarter decisions every day.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final progress = _beltThreeIntro.value;
                          return Opacity(
                            opacity: progress,
                            child: Transform.translate(
                              offset: Offset(0, (1 - progress) * 18),
                              child: child,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: isSmallScreen ? 250 : 250,
                          height: isSmallScreen ? 80 : 90,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) {
                              if (!_isButtonHovered) {
                                setState(() => _isButtonHovered = true);
                              }
                            },
                            onExit: (_) {
                              if (_isButtonHovered) {
                                setState(() => _isButtonHovered = false);
                              }
                            },
                            child: AnimatedScale(
                              scale: _isButtonHovered ? 1.06 : 1.0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _startApp(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/denim/button.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Text(
                                        'GET STARTED',
                                        style: TextStyle(
                                          fontFamily: 'Cartoon',
                                          fontSize: isSmallScreen ? 14 : 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 80 : 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
