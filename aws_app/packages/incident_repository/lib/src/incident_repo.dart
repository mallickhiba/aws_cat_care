import 'package:incident_repository/src/models/incident.dart';

abstract class IncidentRepository {
  createIncident(Incident incident, String catId) {}

  updateIncident(Incident incident) {}

  deleteIncident(String incidentId) {}

  Future<List<Incident>> getAllIncidents();

  Future<List<Incident>> getIncidentsForCat(String catId);
}
