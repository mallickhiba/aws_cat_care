import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('GetAllUsersBloc', () {
    final mockUserRepository = MockUserRepository();
    final user = MyUser(id: '1', email: '', name: '', role: '');
    final List<MyUser> users = [user];

    when(() => mockUserRepository.getAllUsers()).thenAnswer((_) async => users);

    blocTest<GetAllUsersBloc, GetAllUsersState>(
      'handles GetAllUsers sucessfully',
      build: () => GetAllUsersBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(FetchAllUsers()),
      expect: () =>
          <GetAllUsersState>[GetAllUsersLoading(), GetAllUsersSuccess(users)],
    );

    blocTest<GetAllUsersBloc, GetAllUsersState>(
      'handles GetAllUsers when it fails',
      build: () => GetAllUsersBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getAllUsers())
            .thenThrow(Exception('Failed to fetch users'));
      },
      act: (bloc) => bloc.add(FetchAllUsers()),
      expect: () =>
          <GetAllUsersState>[GetAllUsersLoading(), const GetAllUsersFailure()],
    );
  });
}
