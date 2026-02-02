import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'Login_page.dart';
import 'Sign_up.dart';
import 'main_dashboard.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  void _continueAsGuest() {
    // Navigate directly to dashboard as guest
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive calculations
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        // LayoutBuilder gives us the available constraints of the parent (the screen area)
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ConstrainedBox forces the content to be at least the height of the screen,
              // ensuring the Spacers work correctly when there is enough room.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // IntrinsicHeight is required here to let Spacers expand to fill
                // the remaining height within the scrollable area.
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // --- Header Text ---
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: 'Smart '),
                              TextSpan(
                                text: 'Inventory',
                                style: TextStyle(
                                  color: Color(0xFFE68A00),
                                ), // Orange
                              ),
                              TextSpan(text: '\nManagement'),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // --- Central Illustration ---
                        Center(
                          child: SizedBox(
                            width: size.width * 0.8,
                            height: size.width * 0.7,
                            child: CustomPaint(
                              painter: InventoryIllustrationPainter(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // --- Subtext below illustration ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            textAlign: TextAlign.right,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(text: 'all in one '),
                                TextSpan(
                                  text: 'place',
                                  style: TextStyle(
                                    color: Color(0xFFE68A00),
                                  ), // Orange
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // --- Buttons ---
                        _buildButton(
                          text: 'Sign in',
                          backgroundColor: const Color(0xFF5AB2C3), // Teal
                          textColor: Colors.black,
                          onTap: () {
                            // Navigate to Login Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildButton(
                          text: 'Sign up',
                          backgroundColor: const Color(0xFFD9D9D9), // Grey
                          textColor: Colors.black,
                          onTap: () {
                            // Navigate to Sign Up Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // --- Continue as Guest ---
                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFFE68A00),
                                )
                              : TextButton(
                                  onPressed: _continueAsGuest,
                                  child: const Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      color: Color(0xFFE68A00),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                        ),

                        // Extra padding at the bottom ensures it doesn't look cut off if scrolling happens
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Custom Painter for the Gears and Boxes Illustration ---
// This draws the vector art programmatically so no assets are needed.
class InventoryIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintStroke = Paint()
      ..color =
          const Color(0xFF5786FF) // The main blue outline color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = const Color(0xFFA3C4FA)
          .withOpacity(0.5) // Light blue fill
      ..style = PaintingStyle.fill;

    final bgCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Background circle effect
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.45,
      bgCirclePaint,
    );

    // --- Draw Gears ---
    _drawGear(
      canvas,
      Offset(size.width * 0.35, size.height * 0.25),
      size.width * 0.15,
      paintFill,
      paintStroke,
    );
    _drawGear(
      canvas,
      Offset(size.width * 0.65, size.height * 0.35),
      size.width * 0.12,
      paintFill,
      paintStroke,
    );

    // --- Draw Boxes ---
    // Box 1 (Top Left of stack)
    _drawBox(
      canvas,
      Offset(size.width * 0.05, size.height * 0.35),
      size.width * 0.22,
      paintFill,
      paintStroke,
    );

    // Box 2 (Bottom Left)
    _drawBox(
      canvas,
      Offset(size.width * 0.15, size.height * 0.55),
      size.width * 0.22,
      paintFill,
      paintStroke,
    );

    // Box 3 (Bottom Right)
    _drawBox(
      canvas,
      Offset(size.width * 0.35, size.height * 0.55),
      size.width * 0.25,
      paintFill,
      paintStroke,
    );
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fill,
    Paint stroke,
  ) {
    final double toothLength = radius * 0.25;
    final double outerRadius = radius + toothLength;
    final double innerRadius = radius;
    const int teeth = 8;

    final Path path = Path();

    for (int i = 0; i < teeth; i++) {
      final double angle = (2 * math.pi * i) / teeth;
      final double nextAngle = (2 * math.pi * (i + 1)) / teeth;
      final double toothWidthAngle = (2 * math.pi) / (teeth * 3);

      // Start at inner radius
      if (i == 0) {
        path.moveTo(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        );
      }

      // Line to outer radius (start of tooth)
      path.lineTo(
        center.dx + outerRadius * math.cos(angle + toothWidthAngle * 0.5),
        center.dy + outerRadius * math.sin(angle + toothWidthAngle * 0.5),
      );

      // Line across tooth top
      path.lineTo(
        center.dx + outerRadius * math.cos(angle + toothWidthAngle * 1.5),
        center.dy + outerRadius * math.sin(angle + toothWidthAngle * 1.5),
      );

      // Line back to inner radius
      path.lineTo(
        center.dx + innerRadius * math.cos(nextAngle),
        center.dy + innerRadius * math.sin(nextAngle),
      );
    }

    path.close();

    // Inner hole
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.4));
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Inner circle outline (hole)
    canvas.drawCircle(center, radius * 0.4, stroke);
  }

  void _drawBox(
    Canvas canvas,
    Offset topLeft,
    double width,
    Paint fill,
    Paint stroke,
  ) {
    final rect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      width,
      width,
    ); // Square boxes

    // Main Box shape
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);

    // Box details (the tape/flap look)
    // Small inner square/tape at top center
    final tapeRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top + rect.height * 0.25),
      width: rect.width * 0.4,
      height: rect.height * 0.3,
    );

    // We only draw the bottom half of the tape line usually, but let's draw a simple detail line
    final detailPath = Path();
    // Tape vertical lines
    detailPath.moveTo(tapeRect.left, rect.top);
    detailPath.lineTo(tapeRect.left, tapeRect.bottom);
    detailPath.lineTo(tapeRect.right, tapeRect.bottom);
    detailPath.lineTo(tapeRect.right, rect.top);

    // Horizontal line near bottom
    detailPath.moveTo(rect.left + 10, rect.bottom - 15);
    detailPath.lineTo(rect.right - 10, rect.bottom - 15);

    canvas.drawPath(detailPath, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
