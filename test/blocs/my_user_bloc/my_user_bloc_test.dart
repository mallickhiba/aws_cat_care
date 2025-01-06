import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements MyUser {}

void main() {
  group('GetUserBloc', () {
    final mockUserRepository = MockUserRepository();
    final user = MockUser();
    var called = false;

    when(() => mockUserRepository.getMyUser('1')).thenAnswer((_) async {
      called = true;
      return user;
    });

    blocTest<MyUserBloc, MyUserState>('handles GetMyUser successfully',
        build: () => MyUserBloc(myUserRepository: mockUserRepository),
        act: (bloc) => bloc.add(const GetMyUser('1')),
        expect: () => <MyUserState>[MyUserState.success(user)],
        verify: (_) {
          expect(called, true);
        });
  });
}
