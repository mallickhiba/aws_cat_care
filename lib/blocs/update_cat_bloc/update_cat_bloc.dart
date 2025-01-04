import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:equatable/equatable.dart';
part 'update_cat_event.dart';
part 'update_cat_state.dart';

class UpdateCatBloc extends Bloc<UpdateCatEvent, UpdateCatState> {
  UpdateCatBloc({required CatRepository catRepository})
      : super(UpdateCatInitial()) {
    on<UpdateCat>((event, emit) async {
      emit(UpdateCatLoading());
      try {
        await catRepository.updateCat(event.cat);
        emit(UpdateCatSuccess());
      } catch (e) {
        emit(UpdateCatFailure(e.toString()));
      }
    });
  }
}
