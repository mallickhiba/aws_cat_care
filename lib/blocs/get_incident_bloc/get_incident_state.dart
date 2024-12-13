part of 'get_incident_bloc.dart';

abstract class GetIncidentState extends Equatable {
  const GetIncidentState();

  @override
  List<Object> get props => [];
}

final class GetIncidentInitial extends GetIncidentState {}

final class GetIncidentLoading extends GetIncidentState {}

final class GetIncidentSuccess extends GetIncidentState {
  final List<Incident> incidents;

  const GetIncidentSuccess(this.incidents);

  @override
  List<Object> get props => [incidents];
}

final class GetIncidentFailure extends GetIncidentState {
  final String error;

  const GetIncidentFailure(this.error);

  @override
  List<Object> get props => [error];
}
