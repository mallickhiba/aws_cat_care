import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockCatRepository extends Mock implements CatRepository {}

void main() {
  group('GetCatBloc', () {
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
    final List<Cat> cats = [cat];
    var called = false;

    when(() => mockCatRepository.getCatByID('1')).thenAnswer((_) async {
      called = true;
      return cat;
    });

    blocTest<GetCatBloc, GetCatState>('handles GetCatById successfully',
        build: () => GetCatBloc(catRepository: mockCatRepository),
        act: (bloc) => bloc.add(const GetCatById('1')),
        expect: () => <GetCatState>[GetCatLoading(), GetCatByIDSuccess(cat)],
        verify: (_) {
          expect(called, true);
        });

    when(() => mockCatRepository.getCats()).thenAnswer((_) async => cats);

    blocTest<GetCatBloc, GetCatState>(
      'handles GetCats sucessfully',
      build: () => GetCatBloc(catRepository: mockCatRepository),
      act: (bloc) => bloc.add(GetCats()),
      expect: () => <GetCatState>[GetCatLoading(), GetCatSuccess(cats)],
    );

    blocTest<GetCatBloc, GetCatState>(
      'handles GetCats and fails',
      build: () => GetCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.getCats())
            .thenThrow(Exception('Failed to fetch cats'));
      },
      act: (bloc) => bloc.add(GetCats()),
      expect: () => <GetCatState>[GetCatLoading(), GetCatFailure()],
    );

    when(() => mockCatRepository.deleteCat(any())).thenAnswer((_) async {});
    when(() => mockCatRepository.getCats()).thenAnswer((_) async => []);

    blocTest<GetCatBloc, GetCatState>(
      'handles DeleteCat and succeeds',
      build: () => GetCatBloc(catRepository: mockCatRepository),
      act: (bloc) => bloc.add(const DeleteCat('1')),
      expect: () => <GetCatState>[GetCatLoading(), GetCatFailure()],
    );

    blocTest<GetCatBloc, GetCatState>(
      'handles DeleteCat and fails',
      build: () => GetCatBloc(catRepository: mockCatRepository),
      setUp: () {
        when(() => mockCatRepository.deleteCat(any()))
            .thenThrow(Exception('Failed to delete cat'));
      },
      act: (bloc) => bloc.add(const DeleteCat('1')),
      expect: () => <GetCatState>[GetCatFailure()],
    );
  });
}
