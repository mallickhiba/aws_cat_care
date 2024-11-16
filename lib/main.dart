// import 'package:aws_cat_care/components/admin_bottom_nav_bar.dart';
// import 'package:aws_cat_care/components/volunteer_bottom_nav_bar.dart';
import 'package:aws_cat_care/simple_bloc_observer.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //only up
  runApp(MyApp(FirebaseUserRepository()));
}
