import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CatProfilePage extends StatelessWidget {
  final DocumentSnapshot cat;

  const CatProfilePage({Key? key, required this.cat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = cat.data() as Map<String, dynamic>;
    final String catRef = cat.reference.path; // Reference to match incidents

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cat Image
            if (data['imageURL'] != null)
              Image.network(
                data['imageURL'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    '../athena..png',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),

            // Cat Basic Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_pin,
                                      color: Colors.red),
                                  Text(
                                    data['location'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            data['sex'] == 'M' ? Icons.male : Icons.female,
                            color: Colors.pink,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // About Section
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About ${data['name']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 8.0,
                    children: [
                      _buildInfoChip("Age", "${data['age']} years"),
                      _buildInfoChip("Fixed", data['isFixed'] ? 'Yes' : 'No'),
                      _buildInfoChip(
                          "Vaccinated", data['isVaccinated'] ? 'Yes' : 'No'),
                      _buildInfoChip("Color", data['color']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${data['description']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Incidents Section
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incidents',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('incidents')
                        .where('cat', isEqualTo: catRef)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final incidents = snapshot.data?.docs ?? [];
                      if (incidents.isEmpty) {
                        return const Text('No incidents reported.');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: incidents.length,
                        itemBuilder: (context, index) {
                          final incidentData =
                              incidents[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(incidentData['description'] ??
                                'No description'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Report Date: ${incidentData['ReportDate']?.toDate().toString() ?? ''}"),
                                Text(
                                    "Vet Visit: ${incidentData['VetVisit'] ? 'Yes' : 'No'}"),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.purple.shade50,
      label: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
