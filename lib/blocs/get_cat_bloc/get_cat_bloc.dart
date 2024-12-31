import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:equatable/equatable.dart';
part 'get_cat_event.dart';
part 'get_cat_state.dart';

class GetCatBloc extends Bloc<GetCatEvent, GetCatState> {
  final CatRepository _catRepository;

  GetCatBloc({required CatRepository catRepository})
      : _catRepository = catRepository,
        super(GetCatInitial()) {
    on<GetCats>((event, emit) async {
      emit(GetCatLoading());
      try {
        List<Cat> cats = await _catRepository.getCat();
        emit(GetCatSuccess(cats));
      } catch (e) {
        emit(GetCatFailure());
      }
    });
    on<DeleteCat>((event, emit) async {
      try {
        await catRepository.deleteCat(event.catId);
        add(GetCats()); // Refresh the list after deletion
      } catch (error) {
        emit(GetCatFailure());
      }
    });
  }
}
