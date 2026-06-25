import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/screens/history_screen.dart';

void main() {
  group('formatPredictionDate', () {
    test('formats Firestore timestamps into a readable date string', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 6, 25, 14, 30));

      expect(formatPredictionDate(timestamp), '25/6/2026');
    });

    test('returns a fallback for missing timestamps', () {
      expect(formatPredictionDate(null), 'Just now');
    });
  });
}
