import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
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

        if (googleUser == null) {
          throw Exception('User cancelled sign-in');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to FirebaseAuth with the Google credentials
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Check if the user exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        log("Google Sign-In successful: UID = ${userCredential.user!.uid}, Email = ${userCredential.user!.email}");

        if (!userDoc.exists) {
          // If user does not exist, create a new user record
          final user = MyUser(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            name: userCredential.user!.displayName ?? 'Unknown Name',
            role: '', // Default role
            picture: '',
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .set(user.toEntity().toDocument());
        }

        emit(GoogleSignInSuccess());
      } catch (error) {
        log("Google Sign-In error: $error");
        emit(GoogleSignInFailure());
      }
    });
  }
}
