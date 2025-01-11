part of 'authentication_bloc.dart';

// Base class for all authentication states
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationStateUnknown extends AuthenticationState {}

class AuthenticationStateAuthenticated extends AuthenticationState {
  final User user;

  const AuthenticationStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticationStateUnauthenticated extends AuthenticationState {}

class AuthenticationStateProcessing extends AuthenticationState {}

// Sign Up States:
class SignUpInitial extends AuthenticationState {}

class SignUpSuccess extends AuthenticationState {}

class SignUpFailure extends AuthenticationState {}

class SignUpProcess extends AuthenticationState {}

// Sign In States:
class SignInInitial extends AuthenticationState {}

class SignInSuccess extends AuthenticationState {}

class SignInFailure extends AuthenticationState {
  final String? message;

  const SignInFailure({this.message});
}

class SignInProcess extends AuthenticationState {}

class GoogleSignInSuccess extends AuthenticationState {}

class GoogleSignInFailure extends AuthenticationState {}
