enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.errorMessage,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated() : this(status: AuthStatus.authenticated);

  const AuthState.unauthenticated({String? errorMessage})
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  final AuthStatus status;
  final String? errorMessage;
}
