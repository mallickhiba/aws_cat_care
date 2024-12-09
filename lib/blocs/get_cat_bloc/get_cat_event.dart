part of 'get_cat_bloc.dart';

sealed class GetCatEvent extends Equatable {
  const GetCatEvent();

  @override
  List<Object> get props => [];
}

class GetCats extends GetCatEvent {}
