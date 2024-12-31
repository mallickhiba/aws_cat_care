part of 'get_incidents_for_cat_bloc.dart';

sealed class GetIncidentsForCatEvent extends Equatable {
  const GetIncidentsForCatEvent();

  @override
  List<Object> get props => [];
}

class GetIncidentsForCat extends GetIncidentsForCatEvent {
  final String catId;

  const GetIncidentsForCat({required this.catId});

  @override
  List<Object> get props => [catId];
}

class DeleteIncidentForCat extends GetIncidentsForCatEvent {
  final String incidentId;
  final String catId;

  const DeleteIncidentForCat(this.incidentId, this.catId);

  @override
  List<Object> get props => [incidentId, catId];
}
