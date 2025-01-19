import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_cat_event.dart';
part 'create_cat_state.dart';

class CreateCatBloc extends Bloc<CreateCatEvent, CreateCatState> {
  final CatRepository _catRepository;

  CreateCatBloc({required CatRepository catRepository})
      : _catRepository = catRepository,
        super(CreateCatInitial()) {
    on<CreateCat>((event, emit) async {
      emit(CreateCatLoading());
      try {
        Cat cat = await _catRepository.createCat(event.cat);
        emit(CreateCatSuccess(cat));
      } catch (e) {
        emit(CreateCatFailure());
      }
    });

    on<UpdateCatDetails>((event, emit) {
      // TODO: You can add more complex logic here if needed, such as validation
      emit(CreateCatUpdated(event));
    });
  }
}
