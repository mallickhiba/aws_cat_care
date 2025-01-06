import 'package:bloc_test/bloc_test.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';
import 'package:user_repository/user_repository.dart';

class MockCatRepository extends Mock implements CatRepository {}

void main() {
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
    var called = false;
    when(() => mockCatRepository.createCat(any())).thenAnswer((_) async => cat);

    blocTest<CreateCatBloc, CreateCatState>(
      'emits [CreateCatLoading, CreateCatSuccess] when CreateCat is successful',
      build: () => CreateCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.createCat(cat))
            .thenAnswer((_) async => cat);
      },
      act: (bloc) => bloc.add(CreateCat(cat)),
      expect: () => <CreateCatState>[CreateCatLoading(), CreateCatSuccess(cat)],
    );

    blocTest<CreateCatBloc, CreateCatState>(
        'emits [CreateCatLoading, CreateCatFailure] when CreateCat fails',
        build: () => CreateCatBloc(catRepository: mockCatRepository),
        setUp: () {
          when(() => mockCatRepository.createCat(any()))
              .thenThrow(Exception('Failed to create cat'));
        },
        act: (bloc) => bloc.add(CreateCat(cat)),
        expect: () => <CreateCatState>[CreateCatLoading(), CreateCatFailure()],
        verify: (_) {
          expect(called, isTrue);
        });
  });
}
