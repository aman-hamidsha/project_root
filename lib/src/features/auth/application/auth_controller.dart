import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState.loading()) {
    _initialization = _initialize();
  }

  static const String _accountsStorageKey = 'basic_auth_accounts_v1';
  static const String _sessionStorageKey = 'basic_auth_session_v1';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final Future<void> _initialization;
  Map<String, String> _accounts = <String, String>{};

  Future<void> _initialize() async {
    final prefs = await _prefs;
    final storedAccounts = prefs.getString(_accountsStorageKey);

    if (storedAccounts != null && storedAccounts.isNotEmpty) {
      final decoded = jsonDecode(storedAccounts);
      if (decoded is Map<String, dynamic>) {
        _accounts = decoded.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    }

    await prefs.remove(_sessionStorageKey);
    state = const AuthState.unauthenticated();
  }

  String _normalizeUsername(String username) => username.trim().toLowerCase();

  Future<void> _persistAccounts() async {
    final prefs = await _prefs;
    await prefs.setString(_accountsStorageKey, jsonEncode(_accounts));
  }

  Future<void> _setSignedInUser(String? username) async {
    final prefs = await _prefs;

    if (username == null) {
      await prefs.remove(_sessionStorageKey);
      state = const AuthState.unauthenticated();
      return;
    }

    await prefs.setString(_sessionStorageKey, username);
    state = AuthState.authenticated(username: username);
  }

  Future<void> signOut() async {
    await _initialization;
    await _setSignedInUser(null);
  }

  Future<void> switchAccount() async {
    await signOut();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _initialization;
    final normalizedUsername = _normalizeUsername(username);
    final storedPassword = _accounts[normalizedUsername];

    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid username or password.');
    }

    await _setSignedInUser(normalizedUsername);
    clearError();
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _initialization;
    final normalizedUsername = _normalizeUsername(username);

    if (_accounts.containsKey(normalizedUsername)) {
      throw Exception('That username is already taken.');
    }

    _accounts[normalizedUsername] = password;
    await _persistAccounts();
    await _setSignedInUser(normalizedUsername);
    clearError();
  }

  void setError(String message) {
    state = AuthState.unauthenticated(errorMessage: message);
  }

  void clearError() {
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage != null) {
      state = const AuthState.unauthenticated();
    }
  }
}
