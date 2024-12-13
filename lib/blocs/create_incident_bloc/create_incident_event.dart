part of 'create_incident_bloc.dart';

abstract class CreateIncidentEvent extends Equatable {
  const CreateIncidentEvent();

  @override
  List<Object> get props => [];
}

class CreateIncident extends CreateIncidentEvent {
  final Incident incident;

  const CreateIncident(this.incident);

  @override
  List<Object> get props => [incident];
}
