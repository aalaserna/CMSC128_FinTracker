import 'package:flutter/material.dart';
import 'customizations.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _titleFade;
  Animation<double>? _titleScale;
  Animation<double>? _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    _titleScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.5, 0.7, curve: Curves.easeOut)),
    );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startApp(BuildContext context) async {
    Navigator.push( 
      context,
      MaterialPageRoute(builder: (_) => const CustomizationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _titleFade == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 40.0),
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(0, isSmallScreen ? -120 : -140),
                            child: FadeTransition(
                              opacity: _titleFade!,
                              child: ScaleTransition(
                                scale: _titleScale!,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Welcome to',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 28 : 38,
                                        fontFamily: 'Rafgins',
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 4,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    Text(
                                      'FINS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 80 : 90,
                                        fontFamily: 'Rafgins',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 4,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/fin.png',
                            height: isSmallScreen ? 220 : 250,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isSmallScreen ? 120 : 130,
                    child: FadeTransition(
                      opacity: _buttonFade!,
                      child: Center(
                        child: _HoverAnimatedButton(
                          onPressed: () => _startApp(context),
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverAnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isSmallScreen;

  const _HoverAnimatedButton({
    required this.onPressed,
    required this.isSmallScreen,
  });

  @override
  State<_HoverAnimatedButton> createState() => _HoverAnimatedButtonState();
}

class _HoverAnimatedButtonState extends State<_HoverAnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (isHovering) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 42, 58),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              "Get Started",
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w400,
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}