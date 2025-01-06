part of 'get_all_users_bloc.dart';

abstract class GetAllUsersState extends Equatable {
  const GetAllUsersState();

  @override
  List<Object?> get props => [];
}

class GetAllUsersLoading extends GetAllUsersState {}

class GetAllUsersSuccess extends GetAllUsersState {
  final List<MyUser> users;

  const GetAllUsersSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class GetAllUsersFailure extends GetAllUsersState {
  const GetAllUsersFailure();

  @override
  List<Object?> get props => [];
}
