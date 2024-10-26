import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E33), // Dark background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              const Text(
                'AWSA Cat Care',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Email & Password Text Fields (for future implementation)
              // You can uncomment and modify these if needed
              // TextField(
              //   decoration: const InputDecoration(
              //     hintText: 'Email',
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.white),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.blue),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // TextField(
              //   obscureText: true,
              //   decoration: const InputDecoration(
              //     hintText: 'Password',
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.white),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.blue),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // Google Sign In Button
              _user != null ? Text('Signed in as: ${_user?.email}') : _googleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return SizedBox(
      height: 50,
      width: double.infinity, // Occupy full width
      child: SignInButton(
        Buttons.google,
        text: "Sign in with Google",
        onPressed: _handleGoogleSignIn,
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      final GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithProvider(googleAuthProvider);

      // Get the currently logged-in user
      final User? user = userCredential.user;

      if (user != null) {
        print('Signed in: ${user.uid}');
      }
    } catch (error) {
      print(error);
    }
  }
}