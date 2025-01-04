part of 'update_cat_bloc.dart';

abstract class UpdateCatEvent extends Equatable {
  const UpdateCatEvent();

  @override
  List<Object> get props => [];
}

class UpdateCat extends UpdateCatEvent {
  final Cat cat;

  const UpdateCat(this.cat);
}
