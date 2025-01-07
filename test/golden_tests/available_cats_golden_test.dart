import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/adoption/available_cats_page.dart';
import 'package:aws_app/screens/adoption/available_cats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockGetCatBloc extends Mock implements GetCatBloc {}

class MockUser extends Mock implements MyUser {}

void main() {
  group('AvailableCatsPage Golden Tests', () {
    final mockCatBloc = MockGetCatBloc();
    final mockUser = MyUser(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      role: 'admin',
      picture: '',
    );
    final mockCat = Cat(
        catId: '1',
        catName: 'Fluffy',
        age: 2,
        color: 'White',
        campus: 'Main Campus',
        status: 'Adopted',
        isVaccinated: true,
        isHealthy: true,
        isFixed: true,
        location: 'Building A',
        description: 'A friendly and playful cat.',
        image: 'https://via.placeholder',
        sex: 'male',
        myUser: MyUser.empty);
    final mockCats = [mockCat, mockCat];
    testGoldens('AvailableCatsPage - Loading State', (tester) async {
      when(() => mockCatBloc.state).thenReturn(GetCatLoading());

      await tester.pumpWidgetBuilder(
        BlocProvider<GetCatBloc>(
          create: (_) => mockCatBloc,
          child: AvailableCatsPage(user: mockUser),
        ),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'available_cats_page_loading');
    });

    testGoldens('AvailableCatsPage - Cats Available', (tester) async {
      when(() => mockCatBloc.state).thenReturn(GetCatSuccess(mockCats));

      await tester.pumpWidgetBuilder(
        BlocProvider<GetCatBloc>(
          create: (_) => mockCatBloc,
          child: AvailableCatsPage(user: mockUser),
        ),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'available_cats_page_with_cats');
    });
  });
}
