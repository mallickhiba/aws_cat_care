import 'dart:ui';

import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/screens/cat/cat_detail_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockGetIncidentsForCatBloc extends Mock
    implements GetIncidentsForCatBloc {}

class MockUpdateCatBloc extends Mock implements UpdateCatBloc {}

void main() {
  group('Golden Tests', () {
    testGoldens('CatDetailScreen Golden Test', (tester) async {
      final mockCat = Cat(
        catId: '1',
        catName: 'Grace',
        age: 4,
        color: 'Grey',
        campus: 'Main Campus',
        status: 'Available',
        isVaccinated: true,
        isHealthy: true,
        isFixed: false,
        location: 'Home',
        description: 'description',
        image: 'assets/images/cats/1.png',
        photos: [
          'assets/images/cats/2.png',
          'assets/images/cats/3.png',
          'assets/images/cats/4.png',
        ],
        sex: '',
        myUser: MyUser.empty,
      );

      final mockUser = MyUser(
        id: '123',
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'admin',
        picture: '',
      );

      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc(),
            ),
            BlocProvider<UpdateCatBloc>(
              create: (_) => MockUpdateCatBloc(),
            ),
          ],
          child: CatDetailScreen(cat: mockCat, user: mockUser),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'cat_detail_screen');
    });
  });
}
