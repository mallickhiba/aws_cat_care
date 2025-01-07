import 'dart:ui';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/screens/home_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockMyUserBloc extends MockBloc<MyUserEvent, MyUserState>
    implements MyUserBloc {}

void main() {
  group('Golden Tests', () {
    testGoldens('Home Screen Golden Test', (tester) async {
      final mockMyUserBloc = MockMyUserBloc();
      final mockUser = MyUser(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        role: 'admin',
        picture: '',
      );

      when(() => mockMyUserBloc.state)
          .thenReturn(MyUserState.success(mockUser));

      await tester.pumpWidgetBuilder(
        BlocProvider<MyUserBloc>(
          create: (_) => mockMyUserBloc,
          child: const HomeScreen(),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(HomeScreen), findsOneWidget);
      await screenMatchesGolden(tester, 'home_screen');
    });
  });
}