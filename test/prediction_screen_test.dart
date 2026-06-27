import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/screens/prediction_screen.dart';
import 'package:traindelay_app/services/backend_service.dart';

void main() {
  group('train delay estimation', () {
    test('returns a higher delay for rainy holiday conditions', () {
      final delay = calculateEstimatedDelay(
        trainName: 'Udarata Menike',
        route: 'Colombo → Jaffna',
        day: 'Sunday',
        holiday: 'Yes',
        weather: 'Rainy',
        temperature: 35,
      );

      expect(delay, greaterThanOrEqualTo(20));
    });

    test('keeps the delay within a reasonable range', () {
      final delay = calculateEstimatedDelay(
        trainName: 'Ruhunu Kumari',
        route: 'Colombo → Galle',
        day: 'Wednesday',
        holiday: 'No',
        weather: 'Sunny',
        temperature: 28,
      );

      expect(delay, inInclusiveRange(5, 60));
    });

    test('stores a new prediction record in history', () {
      predictionHistoryNotifier.value = [];
      predictionHistoryNotifier.value = [
        const PredictionRecord(
          trainName: 'Yal Devi',
          route: 'Colombo → Jaffna',
          delayMinutes: 18,
          date: 'Just now',
          accuracy: '95%',
        ),
        ...predictionHistoryNotifier.value,
      ];

      expect(predictionHistoryNotifier.value.first.delayMinutes, 18);
    });
  });
}
