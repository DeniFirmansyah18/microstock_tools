import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final bool isTesting;
  final FlutterSecureStorage _storage;

  UserProfile? _user;
  String _apiKey = '';
  UserTier _currentTier = UserTier.free;
  bool _isLoading = false;

  AuthProvider({
    this.isTesting = false,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    if (!isTesting) {
      _loadPersistedCredentials();
    }
  }

  bool get isLoggedIn => _user != null;
  UserProfile? get user => _user;
  String get apiKey => _apiKey;
  UserTier get currentTier => _currentTier;
  bool get isLoading => _isLoading;

  Future<void> _loadPersistedCredentials() async {
    try {
      final savedKey = await _storage.read(key: 'gemini_api_key');
      final savedTier = await _storage.read(key: 'user_tier');
      if (savedKey != null && savedKey.isNotEmpty) {
        _apiKey = savedKey;
      }
      if (savedTier == 'pro') {
        _currentTier = UserTier.pro;
      }
      notifyListeners();
    } catch (_) {
      // Storage unavailable in non-mobile test
    }
  }

  /// Performs Google Sign-In authentication flow
  Future<void> signInWithGoogle({
    String name = 'Contributor Studio',
    String email = 'user@stockcraft.io',
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulated network authentication delay for realism
    if (!isTesting) {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _user = UserProfile(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: name,
      email: email,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop',
      tier: _currentTier,
      maxDailyQuota: _currentTier == UserTier.pro ? 500 : 50,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sets or updates the user's Gemini API Key (stored encrypted)
  Future<void> setGeminiApiKey(String key, {bool isPro = false}) async {
    _apiKey = key.trim();
    _currentTier = isPro ? UserTier.pro : UserTier.free;

    if (_user != null) {
      _user = _user!.copyWith(
        tier: _currentTier,
        maxDailyQuota: isPro ? 500 : 50,
      );
    }

    if (!isTesting) {
      try {
        await _storage.write(key: 'gemini_api_key', value: _apiKey);
        await _storage.write(key: 'user_tier', value: isPro ? 'pro' : 'free');
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Disconnects current session
  Future<void> signOut() async {
    _user = null;
    _apiKey = '';
    _currentTier = UserTier.free;

    if (!isTesting) {
      try {
        await _storage.deleteAll();
      } catch (_) {}
    }

    notifyListeners();
  }
}
