// ignore: unused_import
import 'package:aws_cat_care/pages/signin_page.dart';
import 'package:aws_cat_care/pages/welcome_page.dart';
import 'package:aws_cat_care/pages/cats.dart';



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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Cat Care',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
       '/SignInPage': (context) => const SignInPage(),
       '/Cats': (context) => CatsPage(),
      },
    );
  }
}
