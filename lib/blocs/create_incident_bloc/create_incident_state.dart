part of 'create_incident_bloc.dart';

abstract class CreateIncidentState extends Equatable {
  const CreateIncidentState();

  @override
  List<Object> get props => [];
}

final class CreateIncidentInitial extends CreateIncidentState {}

final class CreateIncidentFailure extends CreateIncidentState {}

final class CreateIncidentLoading extends CreateIncidentState {}

final class CreateIncidentSuccess extends CreateIncidentState {
  final Incident incident;

  const CreateIncidentSuccess(this.incident);
}
