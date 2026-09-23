import '../models/auth_model.dart';

class AuthPresenter {
  final AuthModel _model;

  AuthPresenter({AuthModel? model}) : _model = model ?? AuthModel();

  Future<String?> login(String email, String password) async {
    final error = _validateCredentials(email, password);
    if (error != null) return error;

    return _model.login(email.trim(), password);
  }

  Future<String?> signUp(String email, String password) async {
    final error = _validateCredentials(email, password);
    if (error != null) return error;

    return _model.signUp(email.trim(), password);
  }

  // Lab 4 enhancement: validate input before contacting Firebase.
  String? _validateCredentials(String email, String password) {
    if (email.trim().isEmpty) {
      return 'Please enter your email.';
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      return 'Please enter a valid email address.';
    }

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  Future<void> logout() => _model.signOut();

  Stream authStateChanges() => _model.authStateChanges();

  String? getCurrentUserEmail() => _model.currentUser?.email;
}