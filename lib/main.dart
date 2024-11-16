// import 'package:aws_cat_care/components/admin_bottom_nav_bar.dart';
// import 'package:aws_cat_care/components/volunteer_bottom_nav_bar.dart';
import 'package:aws_cat_care/simple_bloc_observer.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';

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
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //only up
  runApp(MyApp(FirebaseUserRepository()));
}
