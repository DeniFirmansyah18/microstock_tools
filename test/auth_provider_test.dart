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
      await auth.signInWithGoogle(
        name: 'Alex Contributor',
        email: 'alex@microstock.io',
      );

      expect(auth.isLoggedIn, isTrue);
      expect(auth.user?.displayName, 'Alex Contributor');
      expect(auth.user?.email, 'alex@microstock.io');
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
