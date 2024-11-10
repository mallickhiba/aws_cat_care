import 'package:aws_cat_care/pages/signin_page.dart';
import 'package:aws_cat_care/pages/signup_page.dart';

import 'package:aws_cat_care/pages/welcome_page.dart';
import 'package:aws_cat_care/pages/volunteer_dashboard.dart';
import 'package:aws_cat_care/pages/panel_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBUcvzwfZuS_GD5BEMQJVqQU_poPVx-LC4",
            authDomain: "aws-cat-care.firebaseapp.com",
            projectId: "aws-cat-care",
            storageBucket: "aws-cat-care.appspot.com",
            messagingSenderId: "719418946649",
            appId: "1:719418946649:web:bf45097ff33a5568b62d48",
            measurementId: "G-T2L9MHZ5BJ"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Cat Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          '/', // Set initial route to home, where the welcome page will be shown
      routes: {
        '/': (context) =>
            MainScreen(), // Main screen checks the user login status
        '/signin': (context) => SignInPage(), // SignIn page
        '/signup': (context) => SignUpPage(), // SignUp page
        '/panel-dashboard': (context) => PanelDashboard(), // Admin dashboard
        '/volunteer-dashboard': (context) =>
            VolunteerDashboard(), // Volunteer dashboard
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data != null) {
          UserHelper.saveUser(snapshot.data!);
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.hasData && snapshot.data != null) {
                final userDoc = snapshot.data;
                final user = userDoc?.data() as Map<String, dynamic>?;
                if (user?['role'] == 'admin') {
                  // Navigate to the panel dashboard if admin
                  return PanelDashboard();
                } else {
                  // Navigate to the volunteer dashboard
                  return VolunteerDashboard();
                }
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        // Show Welcome page if user is not signed in
        return SignInPage();
      },
    );
  }
}
