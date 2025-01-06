import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockCatRepository extends Mock implements CatRepository {}

void main() {
  group('UpdateCatBloc', () {
    final mockCatRepository = MockCatRepository();
    final cat = Cat(
        catId: '1',
        catName: 'Test',
        location: 'Shelter',
        age: 4,
        sex: 'Female',
        color: 'White',
        description: 'Very calm and friendly',
        image: 'path_to_image',
        isFixed: true,
        myUser: MyUser.empty,
        isVaccinated: true,
        isHealthy: true,
        campus: 'Main',
        status: 'Adopted');

    blocTest<UpdateCatBloc, UpdateCatState>(
      'handles UpdateCat and succeeds',
      build: () => UpdateCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.updateCat(cat)).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(UpdateCat(cat)),
      expect: () => <UpdateCatState>[UpdateCatLoading(), UpdateCatSuccess()],
    );

    blocTest<UpdateCatBloc, UpdateCatState>(
      'handles UpdateCat and fails',
      build: () => UpdateCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.updateCat(cat))
            .thenThrow(Exception('Failed to update cat'));
      },
      act: (bloc) => bloc.add(UpdateCat(cat)),
      expect: () => <UpdateCatState>[
        UpdateCatLoading(),
        UpdateCatFailure('Exception: Failed to update cat')
      ],
    );
  });
}
