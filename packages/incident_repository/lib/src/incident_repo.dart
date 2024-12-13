import 'package:incident_repository/src/models/incident.dart';

abstract class IncidentRepository {
  createIncident(Incident incident) {}
  Future<List<Incident>> getIncident();

  updateIncident(Incident incident) {}

  deleteIncident(String incidentId) {}

  Future<List<Incident>> fetchIncidentsForCat(String catId) {
    throw UnimplementedError();
  }

  associateIncidentWithCat(String catId, String incidentId) {}
}
