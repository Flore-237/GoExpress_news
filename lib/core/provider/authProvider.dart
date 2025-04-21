import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/userModel.dart';
import '../../data/service/authenService.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authenticationServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance
      .authStateChanges()
      .asyncMap((user) async {
    if (user == null) {
      return null; // User not logged in.
    }
    // Retrieve user info from Firestore
    final authService = ref.watch(authenticationServiceProvider);
    return await authService.getCurrentUser(); // Make sure this returns UserModel?
  });
});

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.watch(authenticationServiceProvider));
});

class LoginState {
  final bool isLoading;
  final String? error;
  final UserModel? user; // Changed to UserModel?

  LoginState({
    this.isLoading = false,
    this.error,
    this.user,
  });
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(LoginState());

  Future<void> signIn(String email, String password) async {
    state = LoginState(isLoading: true);
    try {
      final user = await _authService.signIn(email, password);
      state = LoginState(user: user);
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }

  Future<void> signUp(String fullName, String email, String password, String phoneNumber) async {
    state = LoginState(isLoading: true);
    try {
      final user = await _authService.signUp(
          fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phoneNumber
      );
      state = LoginState(user: user);
    } catch (e) {
      state = LoginState(error: e.toString());
    }
  }

  void signOut() {
    _authService.signOut();
    state = LoginState();
  }
}