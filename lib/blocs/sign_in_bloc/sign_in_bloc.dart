import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await _userRepository.signIn(event.email, event.password);
        emit(SignInSuccess());
      } catch (e) {
        log(e.toString());
        emit(const SignInFailure());
      }
    });
    on<SignOutRequired>((event, emit) async {
      await _userRepository.logOut();
    });

    on<GoogleSignInRequested>((event, emit) async {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        emit(SignInProcess());
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          // Use Firebase credentials to sign in
          final authCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Authenticate with Firebase
          await _userRepository.signInWithCredential(authCredential);

          emit(GoogleSignInSuccess());
        } else {
          throw Exception('User cancelled sign-in');
        }
      } catch (error) {
        log("Google sign-in error: $error");
        emit(GoogleSignInFailure());
      }
    });
  }
}
