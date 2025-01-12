import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'my_user_event.dart';
part 'my_user_state.dart';

class MyUserBloc extends Bloc<MyUserEvent, MyUserState> {
  final UserRepository _userRepository;

  MyUserBloc({required UserRepository myUserRepository})
      : _userRepository = myUserRepository,
        super(const MyUserState.loading()) {
    log("HELLLOOOO");
    on<GetMyUser>((event, emit) async {
      try {
        log("TRYING TO FIND USERRRR");
        final myUser = await _userRepository.getMyUser(event.myUserId);
        log('FOUND USERRRR');
        log(myUser.toString());
        emit(MyUserState.success(myUser));
        log("EMITTEDD SUCESSS");
      } catch (e) {
        log(e.toString());
        emit(const MyUserState.failure());
      }
    });
  }
}
