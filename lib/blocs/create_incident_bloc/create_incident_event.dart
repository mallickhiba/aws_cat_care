part of 'create_incident_bloc.dart';

abstract class CreateIncidentEvent extends Equatable {
  const CreateIncidentEvent();

  @override
  List<Object> get props => [];
}

class CreateIncident extends CreateIncidentEvent {
  final Incident incident;
  final String catId;

  const CreateIncident(this.incident, this.catId);

  @override
  List<Object> get props => [incident, catId];
}
