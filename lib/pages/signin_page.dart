import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
              _user != null
                  ? Text('Signed in as: ${_user?.email}')
                  : _googleSignInButton(),
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });

      // Save user data to Firestore after successful sign-in
      if (_user != null) {
        UserHelper.saveUser(_user!);
      }

      print('Signed in: ${_user?.email}');
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
  }
}

class UserHelper {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static saveUser(User user) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    Map<String, dynamic> data = {
      'email': user.email,
      'name': user.displayName,
      'role': 'user',
      'photoURL': user.photoURL,
      'last_login': user.metadata.lastSignInTime?.millisecondsSinceEpoch,
      'created_at': user.metadata.creationTime?.millisecondsSinceEpoch,
      'lastSeen': DateTime.now(),
      'buildNumber': buildNumber,
    };

    final userRef = _db.collection('users').doc(user.uid);
    if ((await userRef.get()).exists) {
      print("User exists, updating data");
      await userRef.update({
        'last_login': user.metadata.lastSignInTime,
        'buildNumber': buildNumber,
      });
    } else {
      print("User doesn't exist, creating new document");
      await userRef.set(data);
    }
    await _saveDevice(user);
  }

  static Future<void> _saveDevice(User user) async {
    DeviceInfoPlugin devicePlugin = DeviceInfoPlugin();
    String? deviceId;
    Map<String, dynamic> deviceData;

    if (Platform.isAndroid) {
      final deviceInfo = await devicePlugin.androidInfo;
      deviceId = deviceInfo.id; // Use deviceInfo.id instead of androidId
      deviceData = {
        'os_version': deviceInfo.version.sdkInt.toString(),
        'platform': 'android',
        'model': deviceInfo.model,
        'device': deviceInfo.device,
      };
    } else if (Platform.isIOS) {
      final deviceInfo = await devicePlugin.iosInfo;
      deviceId = deviceInfo.identifierForVendor;
      deviceData = {
        'os_version': deviceInfo.systemVersion,
        'platform': 'ios',
        'model': deviceInfo.model,
        'device': deviceInfo.name,
      };
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final userRef = _db.collection('users').doc(user.uid);
    final deviceRef = userRef.collection('devices').doc(deviceId);

    if ((await deviceRef.get()).exists) {
      await deviceRef.update({
        'last_seen': nowMs,
      });
    } else {
      await deviceRef.set({
        'last_seen': nowMs,
        ...deviceData,
      });
    }
  }
}
