import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/backend_service.dart';
import 'prediction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color purple = Color(0xFFFF00FF);

  StreamSubscription<List<PredictionRecord>>? _predictionsSub;

  @override
  void initState() {
    super.initState();
    _predictionsSub = BackendService.watchPredictions().listen((records) {
      if (!mounted) return;
      predictionHistoryNotifier.value = records;
    });
  }

  @override
  void dispose() {
    _predictionsSub?.cancel();
    super.dispose();
  }

  Future<void> _deleteRecord(PredictionRecord record) async {
    try {
      await BackendService.deletePrediction(record.id);
      predictionHistoryNotifier.value = predictionHistoryNotifier.value
          .where((item) => item.id != record.id)
          .toList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Prediction History',
          style: GoogleFonts.orbitron(color: cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<PredictionRecord>>(
        valueListenable: predictionHistoryNotifier,
        builder: (context, records, _) {
          if (records.isEmpty) {
            return Center(
              child: Text(
                'No predictions yet',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: records.map((record) {
              final color = record.delayMinutes > 15 ? purple : cyan;
              return Dismissible(
                key: ValueKey(record.id.isNotEmpty ? record.id : '${record.trainName}-${record.date}'),
                direction: record.id.isEmpty ? DismissDirection.none : DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                onDismissed: (_) => _deleteRecord(record),
                child: _historyCard(
                  train: record.trainName,
                  route: record.route,
                  delay: '${record.delayMinutes} min',
                  accuracy: record.accuracy,
                  date: record.date,
                  color: color,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _historyCard({
    required String train,
    required String route,
    required String delay,
    required String accuracy,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.train, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  train,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                delay,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(route, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text('Accuracy: $accuracy', style: const TextStyle(color: Colors.white60)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }
}
