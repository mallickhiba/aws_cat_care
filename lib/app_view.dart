import 'package:aws_cat_care/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:aws_cat_care/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_cat_care/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_cat_care/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_cat_care/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_cat_care/blocs/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:aws_cat_care/screens/authentication/welcome_screen.dart';
import 'package:incident_repository/incident_repository.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'screens/home/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignInBloc(
              userRepository:
                  context.read<AuthenticationBloc>().userRepository),
        ),
        BlocProvider(
          create: (context) => UpdateUserInfoBloc(
              userRepository:
                  context.read<AuthenticationBloc>().userRepository),
        ),
        BlocProvider(
          create: (context) => MyUserBloc(
              myUserRepository:
                  context.read<AuthenticationBloc>().userRepository)
            ..add(
                GetMyUser(context.read<AuthenticationBloc>().state.user!.uid)),
        ),
        BlocProvider(
            create: (context) =>
                GetCatBloc(catRepository: FirebaseCatRepository())
                  ..add(GetCats())),
        BlocProvider<GetAllIncidentsBloc>(
          create: (context) => GetAllIncidentsBloc(
            incidentRepository: FirebaseIncidentRepository(),
          ),
        ),
        BlocProvider<GetIncidentsForCatBloc>(
          create: (context) => GetIncidentsForCatBloc(
            incidentRepository: FirebaseIncidentRepository(),
          ),
        ),
        BlocProvider<CreateIncidentBloc>(
          create: (context) => CreateIncidentBloc(
            incidentRepository: FirebaseIncidentRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AWS Cat Care <3',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
            onSurface: Colors.black,
            primary: Color.fromRGBO(206, 147, 216, 1),
            onPrimary: Colors.black,
            secondary: Color.fromRGBO(244, 143, 177, 1),
            onSecondary: Colors.white,
            tertiary: Color.fromRGBO(255, 204, 128, 1),
            error: Colors.red,
            outline: Color(0xFF424242),
          ),
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          },
        ),
      ),
    );
  }
}
