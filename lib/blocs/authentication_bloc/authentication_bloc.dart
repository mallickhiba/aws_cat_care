import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(AuthenticationStateUnknown()) {
    _userSubscription = userRepository.user.listen((authUser) {
      log('User stream updated: ${authUser?.email}');
      add(AuthenticationUserChanged(authUser));
    });

    on<AuthenticationUserChanged>((event, emit) {
      log('AuthenticationUserChanged event triggered with user: ${event.user?.email}');
      if (event.user != null) {
        emit(AuthenticationStateAuthenticated(event.user!));
      } else {
        emit(AuthenticationStateUnauthenticated());
      }
    });

    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await userRepository.signIn(event.email, event.password);
        emit(SignInSuccess());
      } catch (e) {
        log(e.toString());
        emit(const SignInFailure());
      }
    });

    on<SignOutRequired>((event, emit) async {
      await userRepository.logOut();
    });

    on<GoogleSignInRequested>((event, emit) async {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        emit(SignInProcess());
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser != null) {
          emit(GoogleSignInSuccess());
        } else {
          throw Exception('User cancelled sign-in');
        }
      } catch (error) {
        emit(GoogleSignInFailure());
      }
    });
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        MyUser user = await userRepository.signUp(event.user, event.password);
        await userRepository.setUserData(user);
        emit(SignUpSuccess());
      } catch (e) {
        emit(SignUpFailure());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
