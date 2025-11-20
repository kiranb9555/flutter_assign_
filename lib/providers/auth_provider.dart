import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final String? email;

  const AuthState({
    this.isAuthenticated = false,
    this.username,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Mock login function
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would validate credentials with a backend
    if (email.isNotEmpty && password.isNotEmpty) {
      state = state.copyWith(
        isAuthenticated: true,
        email: email,
        username: email.split('@').first,
      );
      return true;
    }
    return false;
  }

  // Logout function
  void logout() {
    state = const AuthState();
  }
}

// Provider for auth state and notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
