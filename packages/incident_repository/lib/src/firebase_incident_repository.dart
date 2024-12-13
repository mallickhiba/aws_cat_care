//handle all methods
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_repository/incident_repository.dart';

class FirebaseIncidentRepository implements IncidentRepository {
  final FirebaseFirestore _firestore;

  FirebaseIncidentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new incident
  @override
  Future<void> createIncident(Incident incident) async {
    final incidentRef =
        _firestore.collection('incidents').doc(); // Auto-generate ID
    await incidentRef.set(incident.copyWith(id: incidentRef.id).toDocument());
  }

  @override
  Future<List<Incident>> getIncident() async {
    final querySnapshot = await _firestore.collection('incidents').get();
    return querySnapshot.docs
        .map((doc) => Incident.fromEntity(IncidentEntity.fromSnapshot(doc)))
        .toList();
  }

  /// Update an existing incident
  @override
  Future<void> updateIncident(Incident incident) async {
    final incidentRef = _firestore.collection('incidents').doc(incident.id);
    await incidentRef.update(incident.toDocument());
  }

  /// Delete an incident
  @override
  Future<void> deleteIncident(String id) async {
    final incidentRef = _firestore.collection('incidents').doc(id);
    await incidentRef.delete();
  }

  /// Get a stream of all incidents
  Stream<List<IncidentEntity>> getIncidents() {
    return _firestore.collection('incidents').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => IncidentEntity.fromSnapshot(doc)).toList());
  }

  /// Get a single incident by ID
  Future<IncidentEntity?> getIncidentById(String id) async {
    final doc = await _firestore.collection('incidents').doc(id).get();
    if (doc.exists) {
      return IncidentEntity.fromSnapshot(doc);
    }
    return null;
  }

  /// Fetch incidents for a specific cat
  @override
  Future<List<Incident>> fetchIncidentsForCat(String catId) async {
    final querySnapshot = await _firestore
        .collection('incidents')
        .where('catId', isEqualTo: catId)
        .get();

    return querySnapshot.docs
        .map((doc) => Incident.fromEntity(IncidentEntity.fromSnapshot(doc)))
        .toList();
  }

  @override
  Future<void> associateIncidentWithCat(String catId, String incidentId) async {
    final catRef = _firestore.collection('cats').doc(catId);

    await catRef.update({
      'incidents': FieldValue.arrayUnion([incidentId]),
    });
  }
}
