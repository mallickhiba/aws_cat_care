//handle all methods
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseIncidentRepository implements IncidentRepository {
  final incidentCollection = FirebaseFirestore.instance.collection('incidents');

  /// Create a new incident
  @override
  Future<Incident> createIncident(Incident incident, String catId) async {
    try {
      incident.id = const Uuid().v1();
      log('Generated Incident ID: ${incident.id}'); // Log the generated ID

      final incidentDocument = incident.toEntity().toDocument();
      await incidentCollection.doc(incident.id).set(incidentDocument);
      log('Incident successfully saved with ID: ${incident.id}');

      // Update the cat document to include the new incident ID
      final catDocRef =
          FirebaseFirestore.instance.collection('cats').doc(catId);
      await catDocRef.update({
        'incidentIds': FieldValue.arrayUnion([incident.id]), // Add the new ID
      });
      log('Incident added to cat with ID: $catId');

      return incident;
    } catch (e) {
      log('Error creating incident: $e'); // Log any errors that occur
      rethrow; // Rethrow the exception to propagate it
    }
  }

  @override
  Future<List<Incident>> getAllIncidents() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('incidents').get();

      return querySnapshot.docs
          .map((doc) => Incident.fromEntity(IncidentEntity.fromSnapshot(doc)))
          .toList();
    } catch (e) {
      log('Error fetching all incidents: $e');
      rethrow;
    }
  }

  @override
  Future<List<Incident>> getIncidentsForCat(String catId) async {
    try {
      // Fetch the Cat document to get the list of incident IDs
      final catDoc =
          await FirebaseFirestore.instance.collection('cats').doc(catId).get();

      if (!catDoc.exists) {
        log("cat with id not found");
        return [];
      }

      final List<dynamic> incidentIdsDynamic =
          catDoc.data()?['incidentIds'] ?? [];
      final List<String> incidentIds =
          incidentIdsDynamic.map((id) => id.toString()).toList();
      if (incidentIds.isEmpty) {
        log("No incidents found for cat with ID $catId.");
        return [];
      }

      // Fetch incidents using the incidentIds
      final incidentsQuery = await FirebaseFirestore.instance
          .collection('incidents')
          .where(FieldPath.documentId, whereIn: incidentIds)
          .get();

      return incidentsQuery.docs
          .map((doc) => Incident.fromEntity(IncidentEntity.fromSnapshot(doc)))
          .toList();
    } catch (e) {
      log('Error fetching incidents for cat $catId: $e');
      rethrow;

      //   return incidentsQuery.docs
      //       .map((doc) => Incident.fromEntity(doc.data()))
      //       .toList();
      // } catch (e) {
      //   print("Error fetching incidents for cat $catId: $e");
      //   rethrow;
    }
  }

  @override
  Future<void> updateIncident(Incident incident) async {
    final incidentDoc =
        FirebaseFirestore.instance.collection('incidents').doc(incident.id);
    await incidentDoc.update(incident.toEntity().toDocument());
  }

  @override
  Future<void> deleteIncident(String incidentId) async {
    final incidentDoc =
        FirebaseFirestore.instance.collection('incidents').doc(incidentId);
    await incidentDoc.delete();
  }
}
