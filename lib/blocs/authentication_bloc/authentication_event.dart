part of 'authentication_bloc.dart';

// Base class for all authentication-related events
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when the user's authentication status changes
class AuthenticationUserChanged extends AuthenticationEvent {
  final User? user;

  const AuthenticationUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// Event triggered when a user requests to sign in with email and password
class SignInRequired extends AuthenticationEvent {
  final String email;
  final String password;
  const SignInRequired(this.email, this.password);
}

class SignOutRequired extends AuthenticationEvent {
  const SignOutRequired();
}

class GoogleSignInRequested extends AuthenticationEvent {}

// Sign up related events:
class SignUpRequired extends AuthenticationEvent {
  final MyUser user;
  final String password;
  const SignUpRequired(this.user, this.password);
}
