import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incident_repository/incident_repository.dart';

part 'get_incidents_for_cat_event.dart';
part 'get_incidents_for_cat_state.dart';

class GetIncidentsForCatBloc
    extends Bloc<GetIncidentsForCatEvent, GetIncidentsForCatState> {
  final IncidentRepository _incidentRepository;

  GetIncidentsForCatBloc({required IncidentRepository incidentRepository})
      : _incidentRepository = incidentRepository,
        super(GetIncidentsForCatInitial()) {
    on<GetIncidentsForCat>((event, emit) async {
      emit(GetIncidentsForCatLoading());
      try {
        final incidents =
            await _incidentRepository.getIncidentsForCat(event.catId);
        log("Fetched incidents: ${incidents.length}");
        emit(GetIncidentsForCatSuccess(incidents));
      } catch (e) {
        emit(GetIncidentsForCatFailure(e.toString()));
      }
    });
    on<DeleteIncidentForCat>((event, emit) async {
      try {
        await _incidentRepository.deleteIncident(event.incidentId);
        add(GetIncidentsForCat(catId: event.catId));
      } catch (error) {
        emit(const GetIncidentsForCatFailure("Failed to delete incident"));
      }
    });
  }
}
