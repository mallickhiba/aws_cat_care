import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incident_repository/incident_repository.dart';

part 'create_incident_event.dart';
part 'create_incident_state.dart';

class CreateIncidentBloc
    extends Bloc<CreateIncidentEvent, CreateIncidentState> {
  final IncidentRepository incidentRepository;

  CreateIncidentBloc({required this.incidentRepository})
      : super(CreateIncidentInitial()) {
    on<CreateIncident>((event, emit) async {
      emit(CreateIncidentLoading());
      try {
        // Pass catId to the repository
        Incident incident = await incidentRepository.createIncident(
          event.incident,
          event.catId,
        );
        emit(CreateIncidentSuccess(incident));
      } catch (e) {
        emit(CreateIncidentFailure());
      }
    });
  }
}
