import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/auth/models/user_profile.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider auth;

    setUp(() {
      auth = AuthProvider(isTesting: true);
    });

    test('initial state has default guest or unauthenticated user', () {
      expect(auth.isLoggedIn, isFalse);
      expect(auth.currentTier, UserTier.free);
    });

    test('loginWithGoogle updates profile and sets user as logged in', () async {
      // In isTesting mode, signInWithGoogle uses built-in mock data.
      await auth.signInWithGoogle();

      expect(auth.isLoggedIn, isTrue);
      expect(auth.user?.displayName, 'Test Contributor');
      expect(auth.user?.email, 'test@stockcraft.io');
    });

    test('setting API key detects Free vs Pro tier', () async {
      await auth.setGeminiApiKey('AIzaSyCustomPaidKey12345', isPro: true);
      expect(auth.apiKey, 'AIzaSyCustomPaidKey12345');
      expect(auth.currentTier, UserTier.pro);
    });

    test('logout clears credentials', () async {
      await auth.signInWithGoogle();
      await auth.signOut();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.user, isNull);
    });
  });
}
