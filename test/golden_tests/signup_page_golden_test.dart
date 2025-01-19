import 'dart:ui';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:aws_app/screens/authentication/sign_up_screen.dart';

import '../blocs/authentication_bloc_test.dart';
import 'welcome_page_golden_test.dart';

final mockUserRepository = MockUserRepository();
void main() {
  group('Golden Tests', () {
    testGoldens('SignUpScreen Golden Test', (tester) async {
      await loadAppFonts();

      final mockUserRepository = MockUserRepository();
      final mockSignUpBloc = MockSignUpBloc();
      whenListen(
        mockSignUpBloc,
        Stream.fromIterable([SignUpInitial()]),
        initialState: SignUpInitial(),
      );

      await tester.pumpWidgetBuilder(
        BlocProvider<SignUpBloc>(
          create: (_) => SignUpBloc(userRepository: mockUserRepository),
          child: SignUpScreen(),
        ),
        surfaceSize: const Size(375, 812),
      );

      expect(find.byType(SignUpScreen), findsOneWidget);

      await screenMatchesGolden(tester, 'sign_up_screen');
    });
  });
}
