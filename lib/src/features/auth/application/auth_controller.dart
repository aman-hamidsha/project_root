import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_state.dart';

/**
 * AuthController is responsible for managing user authentication state,
 * including login, registration, and session persistence. It uses
 * SharedPreferences to store user accounts and session information locally.
 * The controller provides methods for signing in, signing out, and switching accounts,
 * as well as handling error states during authentication processes.
 */

// Riverpod provider: exposes AuthController globally so any widget can watch/read it
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(), // creates a single AuthController instance
);

class AuthController extends StateNotifier<AuthState> {
  // constructor: starts with a loading state, then kicks off initialization
  AuthController() : super(const AuthState.loading()) {
    _initialization =
        _initialize(); // begin async setup immediately on creation
  }

  static const String _accountsStorageKey =
      'basic_auth_accounts_v1'; // key used to store all user accounts in prefs
  static const String _sessionStorageKey =
      'basic_auth_session_v1'; // key used to store the currently logged-in user

  final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance(); // opens local storage (async, cached)
  late final Future<void>
  _initialization; // holds the init future so other methods can await it before running

  Map<String, String> _accounts =
      <String, String>{}; // in-memory store of username -> password pairs

  Future<void> _initialize() async {
    final prefs = await _prefs; // wait for shared prefs to be ready

    final storedAccounts = prefs.getString(
      _accountsStorageKey,
    ); // load saved accounts JSON string from disk

    if (storedAccounts != null && storedAccounts.isNotEmpty) {
      // if there are saved accounts
      final decoded = jsonDecode(
        storedAccounts,
      ); // parse JSON string into a Dart object
      if (decoded is Map<String, dynamic>) {
        // type-check before using it
        _accounts = decoded.map(
          (key, value) => MapEntry(
            key,
            value.toString(),
          ), // convert each entry to Map<String, String>
        );
      }
    }

    await prefs.remove(
      _sessionStorageKey,
    ); // always clear any saved session on startup — forces fresh login every app launch
    state =
        const AuthState.unauthenticated(); // set state to unauthenticated now that init is done
  }

  // strips whitespace and lowercases the username so "Alice" and "alice " are treated the same
  String _normalizeUsername(String username) => username.trim().toLowerCase();

  Future<void> _persistAccounts() async {
    final prefs = await _prefs;
    await prefs.setString(
      _accountsStorageKey,
      jsonEncode(_accounts),
    ); // serialize accounts map to JSON and save to disk
  }

  Future<void> _setSignedInUser(String? username) async {
    final prefs = await _prefs;

    if (username == null) {
      // null means signing out
      await prefs.remove(_sessionStorageKey); // clear session from disk
      state = const AuthState.unauthenticated(); // update state to logged out
      return;
    }

    await prefs.setString(
      _sessionStorageKey,
      username,
    ); // save logged-in username to disk
    state = AuthState.authenticated(
      username: username,
    ); // update state to logged in
  }

  Future<void> signOut() async {
    await _initialization; // make sure init is done before doing anything
    await _setSignedInUser(null); // pass null to trigger the sign-out path
  }

  Future<void> switchAccount() async {
    await signOut(); // switching account is just signing out — user picks a new account on the login screen
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _initialization; // ensure accounts have been loaded from disk before checking

    final normalizedUsername = _normalizeUsername(username); // clean up input
    final storedPassword =
        _accounts[normalizedUsername]; // look up password for this username

    if (storedPassword == null || storedPassword != password) {
      // no account found, or wrong password
      throw Exception(
        'Invalid username or password.',
      ); // throw — UI layer should catch and display this
    }

    await _setSignedInUser(
      normalizedUsername,
    ); // credentials matched — log the user in
    clearError(); // wipe any previous error message from state
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _initialization; // ensure accounts are loaded before registering

    final normalizedUsername = _normalizeUsername(username); // clean up input

    if (_accounts.containsKey(normalizedUsername)) {
      // check if username is already taken
      throw Exception(
        'That username is already taken.',
      ); // throw — UI layer handles this
    }

    _accounts[normalizedUsername] =
        password; // add new user to the in-memory map
    await _persistAccounts(); // save updated accounts map to disk
    await _setSignedInUser(
      normalizedUsername,
    ); // automatically log in after registering
    clearError(); // clear any stale error messages
  }

  // sets an error message on the unauthenticated state — used by UI to surface login/register failures
  void setError(String message) {
    state = AuthState.unauthenticated(errorMessage: message);
  }

  void clearError() {
    if (state.status == AuthStatus.unauthenticated &&
        state.errorMessage != null) {
      // only clear if there's actually an error to clear
      state =
          const AuthState.unauthenticated(); // reset to clean unauthenticated state with no error
    }
  }
}
