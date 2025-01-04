part of 'get_all_incidents_bloc.dart';

abstract class GetAllIncidentsEvent extends Equatable {
  const GetAllIncidentsEvent();

  @override
  List<Object> get props => [];
}

class GetAllIncidents extends GetAllIncidentsEvent {
  const GetAllIncidents();
  @override
  List<Object> get props => [];
}

class DeleteIncident extends GetAllIncidentsEvent {
  final String incidentId;
  final String catId;

  const DeleteIncident(this.incidentId, this.catId);
}
