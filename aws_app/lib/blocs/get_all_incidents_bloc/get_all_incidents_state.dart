part of 'get_all_incidents_bloc.dart';

abstract class GetAllIncidentsState extends Equatable {
  const GetAllIncidentsState();

  @override
  List<Object> get props => [];
}

final class GetAllIncidentsInitial extends GetAllIncidentsState {}

final class GetAllIncidentsFailure extends GetAllIncidentsState {}

final class GetAllIncidentsLoading extends GetAllIncidentsState {}

final class GetAllIncidentsSuccess extends GetAllIncidentsState {
  final List<Incident> incidents;

  const GetAllIncidentsSuccess(this.incidents);
}
