class AuthState {
  const AuthState({
    required this.isLoading,
    required this.token,
    required this.errorMessage,
  });

  const AuthState.initial()
    : isLoading = false,
      token = null,
      errorMessage = null;

  final bool isLoading;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    String? token,
    String? errorMessage,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: clearToken ? null : (token ?? this.token),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
