import 'package:aws_app/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/blocs/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:aws_app/screens/authentication/welcome_screen.dart';
import 'package:incident_repository/incident_repository.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'screens/home_screen.dart';

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
        BlocProvider<GetAllUsersBloc>(
          create: (context) => GetAllUsersBloc(
            userRepository: context.read<AuthenticationBloc>().userRepository,
          )..add(FetchAllUsers()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AWS Cat Care',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            surface: Color.fromARGB(255, 234, 199, 247),
            onSurface: Colors.black,
            primary: Color.fromARGB(255, 106, 52, 128),
            onPrimary: Colors.white,
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
