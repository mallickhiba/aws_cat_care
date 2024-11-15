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
    const String awsLogoPath = '../logo.png';
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 177, 254, 100),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                awsLogoPath,
                height: 300,
                width: 300,
              ),
              const SizedBox(height: 20),
              const Text(
                'FELINES OF TOMORROW',
                style: TextStyle(
                  color: Color.fromARGB(255, 30, 1, 1),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B60F9),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'GET STARTED >',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to SignIn page
                  Navigator.pushNamed(context, '/signup');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('ALREADY HAVE AN ACCOUNT? LOGIN'),
              ),
              const SizedBox(height: 20),
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
      width: 200,
      child: SignInButton(
        Buttons.google,
        text: "Sign in with Google",
        onPressed: _handleGoogleSignIn,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

      // print('Signed in: ${_user?.email}');
    } catch (error) {
      // print('Error during Google Sign-In: $error');
    }
  }
}

class UserHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static saveUser(User user) async {
    try {
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
        await userRef.update({
          'last_login': user.metadata.lastSignInTime,
          'buildNumber': buildNumber,
        });
      } else {
        await userRef.set(data);
      }
      await _saveDevice(user);
    } catch (e) {
      // print('Error saving user: $e'); // This will show specific error details
    }
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
