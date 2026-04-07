import 'dart:convert';

import 'package:cs310_app/src/features/auth/application/auth_controller.dart';
import 'package:cs310_app/src/features/auth/domain/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('registers a user and persists the normalized account name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      await controller.register(username: 'Alice ', password: 'pw123');

      final state = container.read(authControllerProvider);
      final prefs = await SharedPreferences.getInstance();
      final accounts =
          jsonDecode(prefs.getString('basic_auth_accounts_v1')!)
              as Map<String, dynamic>;

      expect(state.status, AuthStatus.authenticated);
      expect(state.username, 'alice');
      expect(accounts, containsPair('alice', 'pw123'));
    });

    test('rejects invalid credentials after initialization', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'basic_auth_accounts_v1': jsonEncode(<String, String>{
          'alice': 'pw123',
        }),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      await expectLater(
        controller.login(username: 'alice', password: 'wrong'),
        throwsA(isA<Exception>()),
      );

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('signOut clears the active session state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      await controller.register(username: 'bob', password: 'pw456');
      await controller.signOut();

      final state = container.read(authControllerProvider);
      final prefs = await SharedPreferences.getInstance();

      expect(state.status, AuthStatus.unauthenticated);
      expect(prefs.getString('basic_auth_session_v1'), isNull);
    });
  });
}
