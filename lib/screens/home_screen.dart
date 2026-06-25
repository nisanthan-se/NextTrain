import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prediction_screen.dart';
import 'assistant_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color purple = Color(0xFFFF00FF);
  static const Color yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _homeUI(),
            const PredictionScreen(),
            const AssistantScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(
              color: cyan.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, "Home", 0),
            _navItem(Icons.bolt_outlined, "Predict", 1),
            _navItem(Icons.smart_toy_outlined, "Assistant", 2),
            _navItem(Icons.person_outline, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _homeUI() {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SRI LANKA RAILWAYS",
                style: GoogleFonts.orbitron(
                  color: cyan,
                  letterSpacing: 3,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 12),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome to ",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "NextTrain",
                      style: GoogleFonts.orbitron(
                        color: cyan,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: cyan.withValues(alpha: 0.25),
                  ),
                  color: Colors.white.withValues(alpha: 0.03),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.memory,
                      color: cyan,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "AI Prediction Engine Active",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      cyan,
                      Icons.check_circle_outline,
                      "94%",
                      "Accuracy",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      purple,
                      Icons.train,
                      "47",
                      "Live",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      yellow,
                      Icons.access_time,
                      "12m",
                      "Delay",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                "QUICK ACCESS",
                style: GoogleFonts.orbitron(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              _featureCard(
                color: cyan,
                icon: Icons.bolt,
                title: "Predict Delay",
                subtitle: "AI-powered delay prediction",
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
              ),

              const SizedBox(height: 18),

              _featureCard(
                color: purple,
                icon: Icons.smart_toy,
                title: "AI Assistant",
                subtitle: "Chat with railway AI",
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
              ),

              const SizedBox(height: 18),

              _featureCard(
  color: yellow,
  icon: Icons.history,
  title: "History",
  subtitle: "View previous predictions",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  },
),
            ],
          ),
        ),
      ],
    );
  }



  Widget _navItem(
    IconData icon,
    String title,
    int index,
  ) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? cyan : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: active ? cyan : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    Color color,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
          color: Colors.white.withValues(alpha: 0.03),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF00F5FF).withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const gap = 24.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}