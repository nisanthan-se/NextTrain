import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/services/backend_service.dart';

void main() {
  group('PredictionRecord date formatting', () {
    test('formats Firestore timestamps into a readable date string', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 6, 25, 14, 30));

      final record = PredictionRecord.fromFirestoreMap('id1', {
        'trainName': 'Yal Devi',
        'route': 'Colombo → Jaffna',
        'delayMinutes': 12,
        'accuracy': '92%',
        'createdAt': timestamp,
      });

      expect(record.date, '25/6/2026');
    });

    test('returns a fallback for missing timestamps', () {
      final record = PredictionRecord.fromFirestoreMap('id2', {
        'trainName': 'Podi Menike',
        'route': 'Colombo → Galle',
        'delayMinutes': 8,
        'accuracy': '90%',
      });

      expect(record.date, 'Just now');
    });
  });
}
