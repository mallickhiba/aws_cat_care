part of 'update_cat_bloc.dart';

sealed class UpdateCatState extends Equatable {
  const UpdateCatState();

  @override
  List<Object> get props => [];
}

final class UpdateCatInitial extends UpdateCatState {}

class UpdateCatLoading extends UpdateCatState {}

class UpdateCatSuccess extends UpdateCatState {}

class UpdateCatFailure extends UpdateCatState {
  final String error;
  UpdateCatFailure(this.error);
}
