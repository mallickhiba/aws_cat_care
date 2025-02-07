part of 'get_cat_bloc.dart';

sealed class GetCatEvent extends Equatable {
  const GetCatEvent();

  @override
  List<Object> get props => [];
}

class GetCats extends GetCatEvent {}

class GetCatById extends GetCatEvent {
  final String catId;

  const GetCatById(this.catId);
}

class DeleteCat extends GetCatEvent {
  final String catId;

  const DeleteCat(this.catId);
}
