import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/screens/authentication/sign_in_screen.dart';

import '../blocs/authentication_bloc_test.dart';

final mockUserRepository = MockUserRepository();
void main() {
  group('Golden Tests', () {
    testGoldens('SignInScreen Golden Test', (tester) async {
      await loadAppFonts();

      final mockUserRepository = MockUserRepository();
      await tester.pumpWidgetBuilder(
        BlocProvider<SignInBloc>(
          create: (_) => SignInBloc(userRepository: mockUserRepository),
          child: const SignInScreen(),
        ),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'sign_in_screen');
    });
  });
}
