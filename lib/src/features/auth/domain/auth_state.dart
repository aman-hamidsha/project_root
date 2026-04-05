/*
 * this file defines the lightweight auth state model used by the app's
 * auth controller. it keeps track of whether auth is loading, signed in,
 * or signed out, and stores the current username plus any error message.
 */

// simple top-level auth modes used by the state object.
enum AuthStatus { loading, authenticated, unauthenticated }

// immutable auth state passed through the app via riverpod.
class AuthState {
  const AuthState({required this.status, this.username, this.errorMessage});

  // startup state while shared prefs and any saved session info are loading.
  const AuthState.loading() : this(status: AuthStatus.loading);

  // signed-in state carrying the active username.
  const AuthState.authenticated({required String username})
    : this(status: AuthStatus.authenticated, username: username);

  // signed-out state with an optional user-facing error message.
  const AuthState.unauthenticated({String? errorMessage})
    : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  final AuthStatus status;
  final String? username;
  final String? errorMessage;
}
