import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/screens/authentication/welcome_screen.dart';
import 'package:aws_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:mocktail/mocktail.dart';
import '../blocs/authentication_bloc/authentication_bloc_test.dart';

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockSignInBloc extends Mock implements SignInBloc {}

class MockSignUpBloc extends Mock implements SignUpBloc {}

void main() {
  group('Golden Tests', () {
    testGoldens('Welcome Screen Golden Test', (tester) async {
      final mockAuthenticationBloc = MockAuthenticationBloc();
      final mockUserRepository = MockUserRepository();

      when(() => mockAuthenticationBloc.userRepository)
          .thenReturn(mockUserRepository);

      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (_) => mockAuthenticationBloc,
            ),
            BlocProvider<SignInBloc>(
              create: (_) => SignInBloc(userRepository: mockUserRepository),
            ),
            BlocProvider<SignUpBloc>(
              create: (_) => SignUpBloc(userRepository: mockUserRepository),
            ),
          ],
          child: const WelcomeScreen(),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);

      await screenMatchesGolden(tester, 'welcome_screen');
    });
  });
}
