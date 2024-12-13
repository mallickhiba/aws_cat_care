part of 'create_incident_bloc.dart';

abstract class CreateIncidentState extends Equatable {
  const CreateIncidentState();

  @override
  List<Object> get props => [];
}

final class CreateIncidentInitial extends CreateIncidentState {}

class CreateIncidentLoading extends CreateIncidentState {}

class CreateIncidentSuccess extends CreateIncidentState {}

class CreateIncidentFailure extends CreateIncidentState {
  final Object error;

  const CreateIncidentFailure(this.error,
      {required String message, required String errorDetails});

  @override
  List<Object> get props => [error];
}
