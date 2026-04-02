class AuthState {
  const AuthState({
    required this.isLoading,
    required this.token,
    required this.errorMessage,
    this.isverified = false,
  });

  const AuthState.initial()
    : isLoading = false,
      token = null,
      errorMessage = null,
      isverified = false;

  final bool isLoading;
  final String? token;
  final String? errorMessage;
  final bool isverified;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    String? token,
    String? errorMessage,
    bool? isverified,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: clearToken ? null : (token ?? this.token),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isverified: isverified ?? this.isverified,
    );
  }
}
