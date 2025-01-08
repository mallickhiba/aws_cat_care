import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home_screen.dart';

import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/components/strings.dart';
import 'package:aws_app/components/textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _errorMsg;
  bool obscurePassword = true;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool signInRequired = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (state is GoogleSignInSuccess) {
          setState(() {
            signInRequired = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errorMsg = 'Invalid email or password';
          });
        } else if (state is GoogleSignInFailure) {
          setState(() {
            signInRequired = false;
            // Add specific handling for Google Sign-In failure
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Google Sign-In failed. Please try again.")),
            );
          });
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(CupertinoIcons.mail_solid),
                  errorMsg: _errorMsg == 'Invalid email or password'
                      ? _errorMsg
                      : null, // Only show if email/password error
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    } else if (!emailRexExp.hasMatch(val)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: const Icon(CupertinoIcons.lock_fill),
                  errorMsg: _errorMsg == 'Invalid email or password'
                      ? _errorMsg
                      : null,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    } else if (!passwordRexExp.hasMatch(val)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                        iconPassword = obscurePassword
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash_fill;
                      });
                    },
                    icon: Icon(iconPassword),
                  ),
                ),
                const SizedBox(height: 40),
                if (!signInRequired)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SignInBloc>().add(SignInRequired(
                              emailController.text, passwordController.text));
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      context.read<SignInBloc>().add(GoogleSignInRequested());
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.mail_solid),
                        SizedBox(width: 10),
                        Text(
                          'Sign In with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
