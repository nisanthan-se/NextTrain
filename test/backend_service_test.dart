import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/services/backend_service.dart';

void main() {
  group('AppUserProfile', () {
    test('serializes to Firestore data and restores from it', () {
      final profile = AppUserProfile(
        name: 'Nishanthan',
        email: 'nishanthan@example.com',
        location: 'Colombo',
        role: 'NextTrain Premium User',
        predictions: 4,
      );

      final data = profile.toFirestoreMap();
      final restored = AppUserProfile.fromFirestoreMap(data);

      expect(data['name'], 'Nishanthan');
      expect(data['predictions'], 4);
      expect(restored.name, 'Nishanthan');
      expect(restored.email, 'nishanthan@example.com');
      expect(restored.location, 'Colombo');
      expect(restored.predictions, 4);
    });
  });

  group('PredictionRecord', () {
    test('serializes prediction records for Firestore', () {
      const record = PredictionRecord(
        trainName: 'Yal Devi',
        route: 'Colombo → Jaffna',
        delayMinutes: 18,
        date: 'Just now',
        accuracy: '95%',
      );

      final data = record.toFirestoreMap();
      final restored = PredictionRecord.fromFirestoreMap('abc123', {
        ...data,
        'createdAt': null,
      });

      expect(data['trainName'], 'Yal Devi');
      expect(restored.trainName, 'Yal Devi');
      expect(restored.delayMinutes, 18);
    });
  });
}
