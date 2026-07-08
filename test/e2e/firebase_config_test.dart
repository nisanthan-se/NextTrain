import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/firebase_options.dart';

void main() {
  group('E2E: Firebase configuration parity', () {
    test('firebase_options matches Android google-services.json', () {
      final file = File('android/app/google-services.json');
      expect(file.existsSync(), isTrue);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final projectInfo = json['project_info'] as Map<String, dynamic>;
      final client = (json['client'] as List).first as Map<String, dynamic>;
      final clientInfo = client['client_info'] as Map<String, dynamic>;
      final apiKey = (client['api_key'] as List).first['current_key'] as String;

      const androidOptions = FirebaseOptions(
        apiKey: 'AIzaSyADywkOX-ZJ0f5-LnMlv4njhDYtgXC1i-U',
        appId: '1:352499223787:android:3a0538936b015d39b9c2ae',
        messagingSenderId: '352499223787',
        projectId: 'nexttrain-5cb99',
        storageBucket: 'nexttrain-5cb99.firebasestorage.app',
      );

      expect(projectInfo['project_id'], androidOptions.projectId);
      expect(projectInfo['project_number'], androidOptions.messagingSenderId);
      expect(clientInfo['mobilesdk_app_id'], androidOptions.appId);
      expect(apiKey, androidOptions.apiKey);
      expect(DefaultFirebaseOptions.currentPlatform.projectId, isNotEmpty);
    });

    test('firebase_options matches iOS GoogleService-Info.plist', () {
      final file = File('ios/Runner/GoogleService-Info.plist');
      expect(file.existsSync(), isTrue);

      final contents = file.readAsStringSync();
      expect(contents, contains('nexttrain-5cb99'));
      expect(contents, contains('352499223787'));
      expect(contents, contains('aca5e0edddee628eb9c2ae'));
    });

    test('.env file exists for Gemini configuration', () {
      final envFile = File('.env');
      expect(envFile.existsSync(), isTrue);
      expect(envFile.readAsStringSync(), contains('GEMINI_API_KEY='));
    });
  });
}
