import 'dart:developer';

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
        log('Error fetching all cats: $e');
        emit(GetCatFailure());
      }
    });

    on<GetCatById>((event, emit) async {
      emit(GetCatLoading());
      try {
        Cat cat = await _catRepository.getCatByID(event.catId);
        emit(GetCatByIDSuccess(cat));
      } catch (e) {
        log('Error fetching cat by ID: $e');
        emit(GetCatFailure());
      }
    });

    on<DeleteCat>((event, emit) async {
      try {
        await _catRepository.deleteCat(event.catId);
        add(GetCats()); // Refresh the list after deletion
      } catch (error) {
        log('Error deleting cat: $error');
        emit(GetCatFailure());
      }
    });
  }
}
