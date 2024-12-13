part of 'get_incident_bloc.dart';

abstract class GetIncidentEvent extends Equatable {
  const GetIncidentEvent();

  @override
  List<Object> get props => [];
}

class LoadIncident extends GetIncidentEvent {
  final String catId;

  const LoadIncident({required this.catId});

  @override
  List<Object> get props => [catId];
}
