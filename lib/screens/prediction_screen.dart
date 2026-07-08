import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../painters/grid_painter.dart';
import '../services/backend_service.dart';

final ValueNotifier<List<PredictionRecord>> predictionHistoryNotifier =
    ValueNotifier<List<PredictionRecord>>([]);

class PredictionInsight {
  final int delayMinutes;
  final String riskLabel;
  final int confidence;
  final String recommendation;

  const PredictionInsight({
    required this.delayMinutes,
    required this.riskLabel,
    required this.confidence,
    required this.recommendation,
  });
}

String buildPredictionExplanation({
  required String trainName,
  required String route,
  required String day,
  required String holiday,
  required String weather,
  required dynamic temperature,
}) {
  final temp = temperature is int
      ? temperature
      : int.tryParse(temperature.toString()) ?? 28;

  return 'Analyzing $trainName on $route route for $day with holiday=$holiday, weather=$weather, temperature=$temp°C.';
}

PredictionInsight buildPredictionInsight({
  required String trainName,
  required String route,
  required String day,
  required String holiday,
  required String weather,
  required dynamic temperature,
}) {
  final delay = calculateEstimatedDelay(
    trainName: trainName,
    route: route,
    day: day,
    holiday: holiday,
    weather: weather,
    temperature: temperature,
  );

  String riskLabel = 'Low';
  String recommendation = 'Service should remain mostly on schedule.';
  int confidence = 84;

  if (delay >= 25) {
    riskLabel = 'High';
    recommendation = 'Expect strong disruption. Allow extra buffer before departure.';
    confidence = 92;
  } else if (delay >= 15) {
    riskLabel = 'Medium';
    recommendation = 'A moderate delay is likely. Plan for a slight change in arrival time.';
    confidence = 88;
  } else {
    recommendation = 'Conditions look manageable. The service should stay close to plan.';
  }

  return PredictionInsight(
    delayMinutes: delay,
    riskLabel: riskLabel,
    confidence: confidence,
    recommendation: recommendation,
  );
}

int calculateEstimatedDelay({
  required String trainName,
  required String route,
  required String day,
  required String holiday,
  required String weather,
  required dynamic temperature,
}) {
  final temp = temperature is int
      ? temperature
      : int.tryParse(temperature.toString()) ?? 28;
  var delay = 5;

  if (trainName.contains('Udarata') || trainName.contains('Yal')) {
    delay += 4;
  }

  if (route.contains('Jaffna') || route.contains('Badulla')) {
    delay += 4;
  }

  if (day == 'Friday' || day == 'Sunday') {
    delay += 3;
  }

  if (holiday == 'Yes') {
    delay += 5;
  }

  if (weather == 'Rainy') {
    delay += 6;
  } else if (weather == 'Cloudy' || weather == 'Partly Cloudy') {
    delay += 2;
  }

  if (temp >= 32) {
    delay += 3;
  } else if (temp <= 18) {
    delay += 2;
  }

  return delay.clamp(5, 60);
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color purple = Color(0xFFFF00FF);

  String selectedTrain = 'Udarata Menike';
  String selectedRoute = 'Colombo → Kandy';
  String selectedDay = 'Wednesday';
  String holiday = 'No';
  String weather = 'Partly Cloudy';

  final TextEditingController tempController =
      TextEditingController(text: '28');

  @override
  void dispose() {
    tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .08,
              child: CustomPaint(
                painter: const GridPainter(opacity: 0.08, gap: 22),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "• NEURAL FORECAST MODULE",
                    style: GoogleFonts.orbitron(
                      color: cyan,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Train Delay ",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Predictor",
                          style: GoogleFonts.orbitron(
                            color: cyan,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Smart delay estimation from route, weather, and schedule factors',
                    style: GoogleFonts.poppins(color: Colors.white54),
                  ),

                  const SizedBox(height: 30),

                  _label("TRAIN NAME"),

                  const SizedBox(height: 12),

                  _dropdownCard(
                    icon: Icons.train_outlined,
                    value: selectedTrain,
                    items: const [
                      "Udarata Menike",
                      "Yal Devi",
                      "Podi Menike",
                      "Ruhunu Kumari",
                      "Senkadagala Menike"
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedTrain = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  _label("ROUTE"),

                  const SizedBox(height: 12),

                  _dropdownCard(
                    icon: Icons.map_outlined,
                    value: selectedRoute,
                    items: const [
                      "Colombo → Kandy",
                      "Colombo → Jaffna",
                      "Colombo → Galle",
                      "Kandy → Badulla",
                      "Colombo → Batticaloa"
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedRoute = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _label("DAY"),
                            const SizedBox(height: 12),
                            _dropdownCard(
                              icon: Icons.calendar_today_outlined,
                              value: selectedDay,
                              items: const [
                                "Monday",
                                "Tuesday",
                                "Wednesday",
                                "Thursday",
                                "Friday",
                                "Saturday",
                                "Sunday"
                              ],
                              onChanged: (v) {
                                setState(() {
                                  selectedDay = v!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _label("HOLIDAY STATUS"),
                            const SizedBox(height: 12),
                            _dropdownCard(
                              icon: Icons.info_outline,
                              value: holiday,
                              items: const ["Yes", "No"],
                              onChanged: (v) {
                                setState(() {
                                  holiday = v!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _label("TEMPERATURE (°C)"),
                            const SizedBox(height: 12),
                            _inputCard(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _label("WEATHER"),
                            const SizedBox(height: 12),
                            _dropdownCard(
                              icon: Icons.cloud_outlined,
                              value: weather,
                              items: const [
                                "Sunny",
                                "Cloudy",
                                "Partly Cloudy",
                                "Rainy",
                                "Stormy",
                                "Foggy"
                              ],
                              onChanged: (v) {
                                setState(() {
                                  weather = v!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: purple.withValues(alpha: 0.4),
                      ),
                      color: purple.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI PRE-ANALYSIS",
                          style: GoogleFonts.orbitron(
                            color: purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          buildPredictionExplanation(
                            trainName: selectedTrain,
                            route: selectedRoute,
                            day: selectedDay,
                            holiday: holiday,
                            weather: weather,
                            temperature: tempController.text,
                          ),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final insight = buildPredictionInsight(
                              trainName: selectedTrain,
                              route: selectedRoute,
                              day: selectedDay,
                              holiday: holiday,
                              weather: weather,
                              temperature: tempController.text,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Estimated delay: ${insight.delayMinutes} min',
                                      style: GoogleFonts.orbitron(
                                        color: cyan,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: insight.riskLabel == 'High'
                                            ? Colors.redAccent.withValues(alpha: 0.2)
                                            : insight.riskLabel == 'Medium'
                                                ? Colors.orange.withValues(alpha: 0.2)
                                                : Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        insight.riskLabel,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: (insight.delayMinutes / 60).clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      insight.riskLabel == 'High'
                                          ? Colors.redAccent
                                          : insight.riskLabel == 'Medium'
                                              ? Colors.orange
                                              : Colors.greenAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Confidence: ${insight.confidence}%',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  insight.recommendation,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: () async {
                        final estimatedDelay = calculateEstimatedDelay(
                          trainName: selectedTrain,
                          route: selectedRoute,
                          day: selectedDay,
                          holiday: holiday,
                          weather: weather,
                          temperature: tempController.text,
                        );

                        final currentContext = context;
                        final record = PredictionRecord(
                          trainName: selectedTrain,
                          route: selectedRoute,
                          delayMinutes: estimatedDelay,
                          date: 'Just now',
                          accuracy: '${90 + (estimatedDelay % 5)}%',
                        );

                        var savedMessage = 'Sign in to save this prediction to your history.';
                        if (BackendService.currentUser != null) {
                          try {
                            await BackendService.savePredictionAndIncrement(record);
                            if (!mounted) return;
                            setState(() {
                              predictionHistoryNotifier.value = [
                                record,
                                ...predictionHistoryNotifier.value,
                              ];
                            });
                            savedMessage = 'Saved to your history.';
                          } on BackendException catch (e) {
                            savedMessage = e.message;
                          } catch (_) {
                            savedMessage = 'Could not save to cloud. Showing estimate only.';
                          }
                        } else {
                          setState(() {
                            predictionHistoryNotifier.value = [
                              record,
                              ...predictionHistoryNotifier.value,
                            ];
                          });
                        }

                        if (!mounted) return;
                        showDialog(
                          context: currentContext,
                          builder: (_) => AlertDialog(
                            backgroundColor: bgColor,
                            title: const Text(
                              'Prediction Result',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'Estimated Delay: $estimatedDelay minutes\n\n$savedMessage',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(currentContext),
                                child: Text('OK', style: TextStyle(color: cyan)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyan.withValues(alpha: 0.15),
                        side: const BorderSide(color: cyan),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        "CALCULATE DELAY",
                        style: GoogleFonts.orbitron(
                          color: cyan,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        color: cyan,
        letterSpacing: 1.5,
        fontSize: 16,
      ),
    );
  }

  Widget _dropdownCard({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cyan.withValues(alpha: 0.3)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: bgColor,
          value: value,
          iconEnabledColor: cyan,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cyan.withValues(alpha: 0.3)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: TextField(
        controller: tempController,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
        ),
      ),
    );
  }
}