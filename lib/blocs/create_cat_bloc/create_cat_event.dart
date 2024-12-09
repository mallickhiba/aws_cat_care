part of 'create_cat_bloc.dart';

sealed class CreateCatEvent extends Equatable {
  const CreateCatEvent();

  @override
  List<Object> get props => [];
}

class CreateCat extends CreateCatEvent {
  final Cat cat;

  const CreateCat(this.cat);
}
