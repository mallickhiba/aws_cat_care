import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'get_all_users_event.dart';
part 'get_all_users_state.dart';

class GetAllUsersBloc extends Bloc<GetAllUsersEvent, GetAllUsersState> {
  final UserRepository _userRepository;

  GetAllUsersBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(GetAllUsersLoading()) {
    on<FetchAllUsers>((event, emit) async {
      emit(GetAllUsersLoading());
      try {
        final users = await _userRepository.getAllUsers();
        emit(GetAllUsersSuccess(users));
      } catch (e) {
        emit(GetAllUsersFailure(error: e.toString()));
      }
    });
  }
}
