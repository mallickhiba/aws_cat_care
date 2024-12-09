part of 'get_cat_bloc.dart';

sealed class GetCatState extends Equatable {
  const GetCatState();

  @override
  List<Object> get props => [];
}

final class GetCatInitial extends GetCatState {}

final class GetCatFailure extends GetCatState {}

final class GetCatLoading extends GetCatState {}

final class GetCatSuccess extends GetCatState {
  final List<Cat> cats;

  const GetCatSuccess(this.cats);
}
