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
      // try {
      //   await incidentRepository.createIncident(event.incident);
      //   emit(CreateIncidentSuccess());
      // } catch (e) {
      //   emit(CreateIncidentFailure(e.toString()));
      // }
      try {
        final incidentRef =
            await incidentRepository.createIncident(event.incident);

        // Associate the new incident ID with the cat
        await incidentRepository.associateIncidentWithCat(
          event.incident
              .cat, // Ensure the catId is included in the incident model
          incidentRef.id, // Use Firestore's generated ID
        );

        emit(CreateIncidentSuccess());
      } catch (e) {
        emit(CreateIncidentFailure(
            message: 'Failed to create incident', errorDetails: e.toString()));
      }
    });
  }
}
