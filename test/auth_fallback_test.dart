import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/services/auth_fallback.dart';

void main() {
  group('shouldUseDemoAuthFallback', () {
    test('returns true for placeholder Firebase credential errors', () {
      const error = 'FirebaseException ([invalid-app-credential] Invalid app credential)';
      expect(shouldUseDemoAuthFallback(error), isTrue);
    });

    test('returns false for real invalid password errors', () {
      const error = 'FirebaseAuthException ([wrong-password] The password is invalid)';
      expect(shouldUseDemoAuthFallback(error), isFalse);
    });
  });
}
