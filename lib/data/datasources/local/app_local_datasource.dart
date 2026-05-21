import 'package:apna_business_app/core/storage/local_storage.dart';
import 'package:apna_business_app/data/models/user_model.dart';

/// Local persistence access for auth and preferences.
class AppLocalDataSource {
  /// Creates the local datasource.
  AppLocalDataSource(this._localStorage);

  final LocalStorage _localStorage;

  /// Reads whether onboarding has been seen.
  bool isOnboardingSeen() => _localStorage.onboardingSeen;

  /// Persists onboarding completion.
  Future<void> setOnboardingSeen() => _localStorage.setOnboardingSeen();

  /// Reads the current theme mode key.
  String getThemeMode() => _localStorage.themeMode;

  /// Persists the current theme mode key.
  Future<void> saveThemeMode(String themeMode) =>
      _localStorage.saveThemeMode(themeMode);

  /// Reads the current language key.
  String getLanguage() => _localStorage.language;

  /// Persists the language key.
  Future<void> saveLanguage(String languageCode) =>
      _localStorage.saveLanguage(languageCode);

  /// Reads the cached current user.
  UserModel? getCurrentUser() {
    final String? userId = _localStorage.userId;
    final String? userName = _localStorage.userName;
    final String? userEmail = _localStorage.userEmail;
    if (userId == null || userName == null || userEmail == null) {
      return null;
    }
    return UserModel(
      id: userId,
      name: userName,
      email: userEmail,
      businessName: _localStorage.businessName,
      businessId: _localStorage.businessId,
    );
  }

  /// Whether a cached session exists.
  bool hasSession() => _localStorage.isLoggedIn;

  /// Reads the current access token.
  String? get currentAccessToken => _localStorage.accessToken;

  /// Saves the authenticated user and tokens.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) {
    return _localStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      businessName: user.businessName,
      businessId: user.businessId,
    );
  }

  /// Clears the local session.
  Future<void> clearSession() => _localStorage.clearSession();
}
