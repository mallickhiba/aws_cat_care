import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incident_repository/incident_repository.dart';
part 'get_incident_event.dart';
part 'get_incident_state.dart';

class GetIncidentBloc extends Bloc<GetIncidentEvent, GetIncidentState> {
  final IncidentRepository incidentRepository;

  GetIncidentBloc({required this.incidentRepository})
      : super(GetIncidentInitial()) {
    {
      on<LoadIncident>((event, emit) async {
        emit(GetIncidentLoading());
        try {
          final incidents =
              await incidentRepository.fetchIncidentsForCat(event.catId);
          emit(GetIncidentSuccess(incidents));
        } catch (e) {
          emit(GetIncidentFailure(e.toString()));
        }
      });
    }
  }
}
