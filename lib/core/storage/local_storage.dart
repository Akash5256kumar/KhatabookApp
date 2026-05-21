import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/utils/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper over [SharedPreferences] for app persistence.
@lazySingleton
class LocalStorage {
  /// Creates a storage wrapper.
  LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  /// Reads whether onboarding was already completed.
  bool get onboardingSeen =>
      _preferences.getBool(AppConstants.keyOnboardingSeen) ?? false;

  /// Reads whether a token is available.
  bool get isLoggedIn =>
      (_preferences.getString(AppConstants.keyAccessToken) ?? '').isNotEmpty;

  /// Reads the persisted user id.
  String? get userId => _preferences.getString(AppConstants.keyUserId);

  /// Reads the persisted business name.
  String? get businessName =>
      _preferences.getString(AppConstants.keyBusinessName);

  /// Reads the persisted business id.
  int? get businessId => _preferences.getInt(AppConstants.keyBusinessId);

  /// Reads the persisted user name.
  String? get userName => _preferences.getString(AppConstants.keyUserName);

  /// Reads the persisted email.
  String? get userEmail => _preferences.getString(AppConstants.keyUserEmail);

  /// Reads the access token.
  String? get accessToken =>
      _preferences.getString(AppConstants.keyAccessToken);

  /// Reads the refresh token.
  String? get refreshToken =>
      _preferences.getString(AppConstants.keyRefreshToken);

  /// Reads the selected language.
  String get language =>
      _preferences.getString(AppConstants.keyLanguage) ??
      AppConstants.langHindi;

  /// Reads the saved theme mode name.
  String get themeMode =>
      _preferences.getString(AppConstants.keyThemeMode) ?? 'system';

  /// Persists onboarding completion.
  Future<void> setOnboardingSeen() async {
    await _guardedWrite(
      () => _preferences.setBool(AppConstants.keyOnboardingSeen, true),
      context: 'set onboarding flag',
    );
  }

  /// Persists theme mode name.
  Future<void> saveThemeMode(String value) async {
    await _guardedWrite(
      () => _preferences.setString(AppConstants.keyThemeMode, value),
      context: 'save theme mode',
    );
  }

  /// Persists language code.
  Future<void> saveLanguage(String value) async {
    await _guardedWrite(
      () => _preferences.setString(AppConstants.keyLanguage, value),
      context: 'save language',
    );
  }

  /// Saves authenticated session details.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,
    required String userEmail,
    String? businessName,
    int? businessId,
  }) async {
    await _guardedWrite(() async {
      await _preferences.setString(AppConstants.keyAccessToken, accessToken);
      await _preferences.setString(AppConstants.keyRefreshToken, refreshToken);
      await _preferences.setString(AppConstants.keyUserId, userId);
      await _preferences.setString(AppConstants.keyUserName, userName);
      await _preferences.setString(AppConstants.keyUserEmail, userEmail);
      if (businessName != null) {
        await _preferences.setString(AppConstants.keyBusinessName, businessName);
      }
      if (businessId != null) {
        await _preferences.setInt(AppConstants.keyBusinessId, businessId);
      }
      return true;
    }, context: 'save session');
  }

  /// Clears only auth-related data.
  Future<void> clearSession() async {
    await _guardedWrite(() async {
      await _preferences.remove(AppConstants.keyAccessToken);
      await _preferences.remove(AppConstants.keyRefreshToken);
      await _preferences.remove(AppConstants.keyUserId);
      await _preferences.remove(AppConstants.keyUserName);
      await _preferences.remove(AppConstants.keyUserEmail);
      await _preferences.remove(AppConstants.keyBusinessName);
      await _preferences.remove(AppConstants.keyBusinessId);
      return true;
    }, context: 'clear session');
  }

  /// Clears the entire storage.
  Future<void> clearAll() async {
    await _guardedWrite(_preferences.clear, context: 'clear storage');
  }

  Future<void> _guardedWrite(
    Future<bool> Function() action, {
    required String context,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      logger.error(
        error,
        message: 'LocalStorage failed to $context',
        stackTrace: stackTrace,
      );
      throw const CacheException();
    }
  }
}
