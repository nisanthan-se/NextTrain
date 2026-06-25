import 'backend_service.dart';

export 'backend_service.dart';

class ProfileSession {
  ProfileSession._();

  static final ProfileSession instance = ProfileSession._();

  AppUserProfile? _currentProfile;

  AppUserProfile? get currentProfile => _currentProfile;

  void setProfile(AppUserProfile profile) {
    _currentProfile = profile;
  }

  void clear() {
    _currentProfile = null;
  }
}
