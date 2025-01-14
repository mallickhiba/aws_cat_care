import 'package:aws_app/screens/incidents/incident_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:intl/intl.dart';

Widget incidentCard({
  required Incident incident,
  required String catName,
  required BuildContext context,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  incident.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.pets,
                  color: Color.fromARGB(255, 106, 52, 128), size: 20),
              const SizedBox(width: 8),
              Text(
                "$catName",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 20, color: Color.fromARGB(255, 106, 52, 128)),
              const SizedBox(width: 8),
              Text(
                "Reported on ${DateFormat('dd MMM yyyy, hh:mm a').format(incident.reportDate.toLocal())}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (incident.vetVisit)
            const Row(
              children: [
                Icon(Icons.local_hospital,
                    size: 20, color: Color.fromARGB(255, 106, 52, 128)),
                SizedBox(width: 8),
                Text(
                  "Vet visit",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          SizedBox(height: 8),
          if (incident.followUp)
            const Row(
              children: [
                Icon(Icons.add_alert,
                    size: 20, color: Color.fromARGB(255, 106, 52, 128)),
                SizedBox(width: 8),
                Text(
                  "Follow up required",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 106, 52, 128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentDetailPage(
                      incident: incident,
                      catName: catName,
                    ),
                  ),
                );
              },
              child: const Text(
                "View Details",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
