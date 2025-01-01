part of 'get_all_users_bloc.dart';

abstract class GetAllUsersEvent extends Equatable {
  const GetAllUsersEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllUsers extends GetAllUsersEvent {}
