import 'package:bloc_test/bloc_test.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';
import 'package:user_repository/user_repository.dart';

class MockCatRepository extends Mock implements CatRepository {}

class MockCat extends Mock implements Cat {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockCat());
  });

  group('CreateCatBloc', () {
    final mockCatRepository = MockCatRepository();
    final cat = Cat(
      catId: '1',
      catName: '',
      location: '',
      age: 3,
      sex: '',
      color: '',
      description: '',
      image: '',
      isFixed: true,
      myUser: MyUser.empty,
      isVaccinated: true,
      isHealthy: true,
      campus: '',
      status: '',
    );

    blocTest<CreateCatBloc, CreateCatState>(
      'handles CreateCat successfully',
      build: () => CreateCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.createCat(cat))
            .thenAnswer((_) async => cat);
      },
      act: (bloc) => bloc.add(CreateCat(cat)),
      expect: () => <CreateCatState>[CreateCatLoading(), CreateCatSuccess(cat)],
    );

    blocTest<CreateCatBloc, CreateCatState>(
      'handles CreateCat when it fails',
      build: () => CreateCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.createCat(any()))
            .thenThrow(Exception('Failed to create cat'));
      },
      act: (bloc) => bloc.add(CreateCat(cat)),
      expect: () => <CreateCatState>[CreateCatLoading(), CreateCatFailure()],
    );
  });
}
