import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/services/profile_session.dart';

void main() {
  test('stores the latest profile details for the active user', () {
    ProfileSession.instance.clear();

    final profile = AppUserProfile(
      name: 'Nishanthan',
      email: 'nishanthan@example.com',
      location: 'Colombo',
      role: 'Premium User',
      predictions: 3,
    );

    ProfileSession.instance.setProfile(profile);

    expect(ProfileSession.instance.currentProfile?.name, 'Nishanthan');
    expect(ProfileSession.instance.currentProfile?.email, 'nishanthan@example.com');
    expect(ProfileSession.instance.currentProfile?.location, 'Colombo');
    expect(ProfileSession.instance.currentProfile?.predictions, 3);
  });
}
