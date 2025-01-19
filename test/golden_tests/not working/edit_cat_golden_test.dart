import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/screens/cat/edit_cat_detail_screen.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockUpdateCatBloc extends Mock implements UpdateCatBloc {}

void main() {
  group('EditCatDetailScreen Golden Tests', () {
    final mockCat = Cat(
      catId: '1',
      catName: 'Whiskers',
      age: 2,
      description: 'A friendly cat.',
      color: 'Brown',
      campus: 'Main Campus',
      status: 'Available',
      isVaccinated: true,
      isHealthy: true,
      isFixed: false,
      image: 'https://example.com/image.jpg',
      location: '',
      sex: '',
      myUser: MyUser.empty,
    );

    testGoldens('Initial State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        BlocProvider<UpdateCatBloc>(
          create: (_) => MockUpdateCatBloc(),
          child: EditCatDetailScreen(cat: mockCat),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'edit_cat_detail_initial');
    });

    testGoldens('Loading State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        BlocProvider<UpdateCatBloc>(
          create: (_) => MockUpdateCatBloc(),
          child: EditCatDetailScreen(cat: mockCat),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.pumpWidget(
        Stack(
          children: [
            EditCatDetailScreen(cat: mockCat),
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );

      await screenMatchesGolden(tester, 'edit_cat_detail_loading');
    });

    testGoldens('Success State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        BlocProvider<UpdateCatBloc>(
          create: (_) => MockUpdateCatBloc()..emit(UpdateCatSuccess()),
          child: EditCatDetailScreen(cat: mockCat),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'edit_cat_detail_success');
    });

    testGoldens('Failure State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        BlocProvider<UpdateCatBloc>(
          create: (_) => MockUpdateCatBloc()
            ..emit(const UpdateCatFailure('Failed to update cat.')),
          child: EditCatDetailScreen(cat: mockCat),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'edit_cat_detail_failure');
    });

    testGoldens('Field Validation Error', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        BlocProvider<UpdateCatBloc>(
          create: (_) => MockUpdateCatBloc(),
          child: EditCatDetailScreen(cat: mockCat.copyWith(catName: '')),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      await screenMatchesGolden(tester, 'edit_cat_detail_validation_error');
    });
  });
}
