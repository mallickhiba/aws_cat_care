import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incident_repository/incident_repository.dart';
part 'get_all_incidents_event.dart';
part 'get_all_incidents_state.dart';

class GetAllIncidentsBloc
    extends Bloc<GetAllIncidentsEvent, GetAllIncidentsState> {
  final IncidentRepository _incidentRepository;

  GetAllIncidentsBloc({required IncidentRepository incidentRepository})
      : _incidentRepository = incidentRepository,
        super(GetAllIncidentsInitial()) {
    on<GetAllIncidents>((event, emit) async {
      emit(GetAllIncidentsLoading());
      try {
        final incidents = await _incidentRepository.getAllIncidents();
        emit(GetAllIncidentsSuccess(incidents));
      } catch (e) {
        emit(GetAllIncidentsFailure());
      }
    });
  }
}
