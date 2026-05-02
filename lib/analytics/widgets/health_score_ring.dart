import 'package:flutter/material.dart';

class HealthScoreRing extends StatefulWidget {
  final double score; // 0–100
  const HealthScoreRing({super.key, required this.score});

  @override
  State<HealthScoreRing> createState() => _HealthScoreRingState();
}

class _HealthScoreRingState extends State<HealthScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _ringColor() {
    if (widget.score >= 70) return const Color(0xFF2E7D32);
    if (widget.score >= 45) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  Color _ringBg() {
    if (widget.score >= 70) return const Color(0xFFE8F5E9);
    if (widget.score >= 45) return const Color(0xFFFFF3E0);
    return const Color(0xFFFFEBEE);
  }

  String _label() {
    if (widget.score >= 70) return 'Excellent';
    if (widget.score >= 45) return 'Fair';
    return 'At Risk';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Track
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(_ringBg()),
                    ),
                  ),
                  // Filled arc
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(_ringColor()),
                    ),
                  ),
                  // Score text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _ringColor(),
                          height: 1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _ringColor().withOpacity(0.55),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _label(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _ringColor(),
                letterSpacing: 0.3,
              ),
            ),
          ],
        );
      },
    );
  }
}