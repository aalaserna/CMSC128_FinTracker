import 'package:flutter/material.dart';
import 'customizations.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  AnimationController? _controller;
  AnimationController? _ambientController;
  AnimationController? _finController;
  Animation<double>? _titleFade;
  Animation<double>? _titleScale;
  Animation<double>? _buttonFade;
  Animation<double>? _box1Fade;
  Animation<double>? _box2Fade;
  Animation<double>? _box3Fade;
  Animation<Offset>? _box1Slide;
  Animation<Offset>? _box2Slide;
  Animation<Offset>? _box3Slide;
  Animation<double>? _finFloat;
  Animation<double>? _bgScale;
  Animation<double>? _rippleDrift;
  Animation<double>? _rippleOpacity;

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

    _box1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.32, 0.5, curve: Curves.easeOut)),
    );

    _box2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.42, 0.6, curve: Curves.easeOut)),
    );

    _box3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.52, 0.7, curve: Curves.easeOut)),
    );

    _box1Slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.32, 0.5, curve: Curves.easeOut)),
    );

    _box2Slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.42, 0.6, curve: Curves.easeOut)),
    );

    _box3Slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller!, curve: const Interval(0.52, 0.7, curve: Curves.easeOut)),
    );

    _ambientController = AnimationController(
      duration: const Duration(milliseconds: 5200),
      vsync: this,
    )..repeat(reverse: true);

    _finController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    )..repeat(reverse: true);

    _finFloat = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _finController!, curve: Curves.easeInOut),
    );

    _bgScale = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut),
    );

    _rippleDrift = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut),
    );

    _rippleOpacity = Tween<double>(begin: 0.78, end: 0.95).animate(
      CurvedAnimation(parent: _ambientController!, curve: Curves.easeInOut),
    );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ambientController?.dispose();
    _finController?.dispose();
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
    if (_controller == null || _titleFade == null || _ambientController == null || _finController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgScale!.value,
                  child: child,
                );
              },
              child: Image.asset(
                "assets/images/water_bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController!,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_rippleDrift!.value, 0),
                  child: Opacity(
                    opacity: _rippleOpacity!.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                "assets/images/ripple.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 56, 38, 97).withOpacity(0.3),
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
                      FadeTransition(
                        opacity: _titleFade!,
                        child: ScaleTransition(
                          scale: _titleScale!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 65,
                                    ),
                                    Text(
                                      "Welcome to",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'Twigs',
                                        color: const Color.fromARGB(255, 30, 42, 58),
                                        fontSize: isSmallScreen ? 30 : 36,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 4,
                                            color: Color.fromARGB(66, 255, 255, 255),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "FINS!",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Anise',
                                            color: const Color.fromARGB(255, 30, 42, 58),
                                            fontSize: isSmallScreen ? 65 : 75,
                                            height: 0.5,
                                            fontWeight: FontWeight.bold,
                                            shadows: const [
                                              Shadow(
                                                offset: Offset(1, 1),
                                                blurRadius: 4,
                                                color: Color.fromARGB(66, 255, 255, 255),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        AnimatedBuilder(
                                          animation: _finController!,
                                          builder: (context, child) {
                                            return Transform.translate(
                                              offset: Offset(0, _finFloat!.value),
                                              child: child,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Image.asset(
                                              "assets/images/fin.png",
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
                                SizedBox(height: 30),
                                FadeTransition(
                                  opacity: _box1Fade!,
                                  child: SlideTransition(
                                    position: _box1Slide!,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.70,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xE5965D).withOpacity(1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "take charge of your finances with ease.",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                FadeTransition(
                                  opacity: _box2Fade!,
                                  child: SlideTransition(
                                    position: _box2Slide!,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.62,
                                        child: Container(
                                          // Adjusting text within container as a right aligned text with too much space on the left
                                          padding: const EdgeInsets.fromLTRB(2, 12, 16, 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xE5965D).withOpacity(1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "track your goals in one simple dashboard.",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                FadeTransition(
                                  opacity: _box3Fade!,
                                  child: SlideTransition(
                                    position: _box3Slide!,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.70,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xE5965D).withOpacity(1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "stay organized and make smarter  decisions every day.",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeTransition(
                        opacity: _buttonFade!,
                        child: Align(
                          alignment: Alignment.center,
                          child: _HoverAnimatedButton(
                            onPressed: () => _startApp(context),
                            isSmallScreen: isSmallScreen,
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
  // Controls the subtle scale animation when hovering.
  late AnimationController _hoverController;
  // Interpolates from normal size to slightly larger size.
  late Animation<double> _scaleAnimation;
  // Tracks pointer hover so we can morph the watercolor background shape.
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    // Short duration for responsive hover feedback.
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      // Uses this State object as ticker provider for animation frames.
      vsync: this,
    );
    // Scale goes from 1.00x to 1.05x while hovering.
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      // Smooth easing for both enter and exit hover.
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    // Rebuild so the watercolor back layer can morph shape.
    setState(() {
      _isHovering = isHovering;
    });

    // Drive the scale animation forward on enter, reverse on exit.
    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Mouse-only hover signals (web/desktop).
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        // Overall button lift/zoom on hover.
        scale: _scaleAnimation,
        child: SizedBox(
          // Matches original CSS button width: 200px (desktop).
          width: widget.isSmallScreen ? 180 : 200,
          // Matches original CSS button height: 50px (desktop).
          height: widget.isSmallScreen ? 55 : 65,
          child: Stack(
            // Keep watercolor layer allowed to slightly overflow.
            clipBehavior: Clip.none,
            children: [
              // Watercolor-like layer (CSS :after equivalent) behind the button.
              Positioned.fill(
                child: AnimatedContainer(
                  // Long linear transition to mimic CSS transition: all 1s linear.
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.linear,
                  // Scale and translate from the center like CSS transform-origin.
                  transformAlignment: Alignment.center,
                  transform: Matrix4.identity()
                    // Small downward nudge like translate(0, 1px).
                    ..translate(0.0, 1.0)
                    // Morph between normal and hover watercolor blob scale.
                    ..scale(_isHovering ? 1.06 : 1.02, _isHovering ? 1.15 : 1.02),
                  decoration: BoxDecoration(
                    // Semi-transparent green watercolor tint.
                    color: const Color.fromARGB(255, 30, 42, 58).withOpacity(0.6),
                    // Hover state gets smoother rounded corners.
                    borderRadius: _isHovering
                        ? BorderRadius.circular(30)
                        // Idle state keeps irregular organic corner profile.
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(40),
                          ),
                  ),
                ),
              ),
              // Foreground transparent button with border + tap interaction.
              Positioned.fill(
                child: Material(
                  // Needed for InkWell ripple on transparent background.
                  color: Colors.transparent,
                  child: InkWell(
                    // Preserves original callback behavior.
                    onTap: widget.onPressed,
                    // Matches top-layer rounded rectangle shape.
                    borderRadius: BorderRadius.circular(10),
                    // Subtle ripple/highlight so effect doesn't overpower watercolor.
                    splashColor: Colors.white.withOpacity(0.08),
                    highlightColor: Colors.white.withOpacity(0.03),
                    child: Container(
                      // Center text exactly like button label in CSS.
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // Keep top layer transparent to reveal watercolor underneath.
                        color: Colors.transparent,
                        border: Border.all(
                          // Dark green border from CSS.
                          color: const Color.fromARGB(255, 30, 42, 58),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "GET STARTED",
                        style: TextStyle(
                          // Slightly smaller on phones to keep proportions.
                          fontFamily: "Twigs",
                          fontSize: widget.isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.bold,
                          // Equivalent to CSS letter-spacing: .5px.
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}