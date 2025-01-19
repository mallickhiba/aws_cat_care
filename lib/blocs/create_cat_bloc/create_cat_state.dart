part of 'create_cat_bloc.dart';

sealed class CreateCatState extends Equatable {
  const CreateCatState();

  @override
  List<Object> get props => [];
}

final class CreateCatInitial extends CreateCatState {}

final class CreateCatFailure extends CreateCatState {}

final class CreateCatLoading extends CreateCatState {}

final class CreateCatSuccess extends CreateCatState {
  final Cat cat;

  const CreateCatSuccess(this.cat);
}

class CreateCatUpdated extends CreateCatState {
  final UpdateCatDetails details;
  const CreateCatUpdated(this.details);

  @override
  List<Object> get props => [details];
}
