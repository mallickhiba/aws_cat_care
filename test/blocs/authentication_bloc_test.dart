import 'package:aws_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AuthenticationBloc', () {
    late MockUserRepository mockUserRepository;
    late AuthenticationBloc bloc;
    late MockUser mockUser;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockUser = MockUser();
      when(() => mockUserRepository.user).thenAnswer(
        (_) => const Stream.empty(),
      );
      bloc = AuthenticationBloc(myUserRepository: mockUserRepository);
    });

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits nothing initially',
      build: () => bloc,
      expect: () => [],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits authenticated(user) when user is not null',
      build: () => bloc,
      setUp: () {
        when(() => mockUserRepository.user).thenAnswer(
          (_) => Stream.value(mockUser),
        );
      },
      act: (bloc) => bloc.add(AuthenticationUserChanged(mockUser)),
      expect: () => [AuthenticationState.authenticated(mockUser)],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits unauthenticated when user is null',
      build: () => bloc,
      setUp: () {
        when(() => mockUserRepository.user).thenAnswer(
          (_) => Stream.value(null),
        );
      },
      act: (bloc) => bloc.add(const AuthenticationUserChanged(null)),
      expect: () => [const AuthenticationState.unauthenticated()],
    );
  });
}
