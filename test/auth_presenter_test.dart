import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/models/auth_model.dart';
import 'package:homework_tracker/presenters/auth_presenter.dart';

class FakeAuthModel extends AuthModel {
  int loginCalls = 0;
  int signupCalls = 0;
  String? receivedEmail;
  String? receivedPassword;
  String? result;

  @override
  Future<String?> login(String email, String password) async {
    loginCalls++;
    receivedEmail = email;
    receivedPassword = password;
    return result;
  }

  @override
  Future<String?> signUp(String email, String password) async {
    signupCalls++;
    receivedEmail = email;
    receivedPassword = password;
    return result;
  }
}

void main() {
  test('Invalid credentials never reach Firebase login or signup', () async {
    final model = FakeAuthModel();
    final presenter = AuthPresenter(model: model);
    for (final credentials in [
      ['', 'abcdef'],
      ['   ', 'abcdef'],
      ['student', 'abcdef'],
      ['student@', 'abcdef'],
      ['student @example.com', 'abcdef'],
      ['student@example.com', ''],
      ['student@example.com', '12345'],
    ]) {
      expect(await presenter.login(credentials[0], credentials[1]), isNotNull);
      expect(await presenter.signUp(credentials[0], credentials[1]), isNotNull);
    }
    expect(model.loginCalls, 0);
    expect(model.signupCalls, 0);
  });

  test('Six-character passwords are accepted and email is trimmed', () async {
    final model = FakeAuthModel();
    final presenter = AuthPresenter(model: model);
    expect(await presenter.signUp(' student@example.com ', '123456'), isNull);
    expect(model.signupCalls, 1);
    expect(model.receivedEmail, 'student@example.com');
    expect(model.receivedPassword, '123456');
  });

  test(
    'Password spaces are preserved when signing up and logging in',
    () async {
      final model = FakeAuthModel();
      final presenter = AuthPresenter(model: model);
      await presenter.signUp('student@example.com', ' secret ');
      expect(model.receivedPassword, ' secret ');
      await presenter.login('student@example.com', ' secret ');
      expect(model.receivedPassword, ' secret ');
    },
  );

  test('Firebase errors are passed back to the view', () async {
    final model = FakeAuthModel()..result = 'Authentication failed';
    final presenter = AuthPresenter(model: model);
    expect(
      await presenter.login('student@example.com', '123456'),
      'Authentication failed',
    );
    expect(
      await presenter.signUp('student@example.com', '123456'),
      'Authentication failed',
    );
  });
}
