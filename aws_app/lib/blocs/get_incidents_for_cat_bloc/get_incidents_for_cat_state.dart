part of 'get_incidents_for_cat_bloc.dart';

sealed class GetIncidentsForCatState extends Equatable {
  const GetIncidentsForCatState();

  @override
  List<Object> get props => [];
}

final class GetIncidentsForCatInitial extends GetIncidentsForCatState {}

class GetIncidentsForCatLoading extends GetIncidentsForCatState {}

class GetIncidentsForCatSuccess extends GetIncidentsForCatState {
  final List<Incident> incidents;

  const GetIncidentsForCatSuccess(this.incidents);

  @override
  List<Object> get props => [incidents];
}

class GetIncidentsForCatFailure extends GetIncidentsForCatState {
  final String error;

  const GetIncidentsForCatFailure(this.error);

  @override
  List<Object> get props => [error];
}
