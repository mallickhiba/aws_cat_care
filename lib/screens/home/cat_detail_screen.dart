import 'package:aws_cat_care/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:aws_cat_care/screens/home/cat_incidents_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:cat_repository/cat_repository.dart';

class CatDetailScreen extends StatelessWidget {
  final Cat cat;

  const CatDetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cat Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(cat.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              _buildReadOnlyField("Name", cat.catName),
              const SizedBox(height: 10),

              // Age
              _buildReadOnlyField("Age", cat.age.toString()),
              const SizedBox(height: 10),

              // Location
              _buildReadOnlyField("Location", cat.location),
              const SizedBox(height: 10),

              // Description
              _buildReadOnlyField("Description", cat.description),
              const SizedBox(height: 10),

              // Sex
              _buildReadOnlyField("Sex", cat.sex),
              const SizedBox(height: 10),

              // Color
              _buildReadOnlyField("Color", cat.color),
              const SizedBox(height: 10),

              // Is Fixed
              _buildReadOnlyField("Fixed", cat.isFixed ? "Yes" : "No"),
              const SizedBox(height: 10),

              // Is Adopted
              _buildReadOnlyField("Adopted", cat.isAdopted ? "Yes" : "No"),
              const SizedBox(height: 20),

              // View Incidents Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => GetIncidentsForCatBloc(
                          incidentRepository: FirebaseIncidentRepository(),
                        )..add(GetIncidentsForCat(catId: cat.catId)),
                        child: IncidentPage(catId: cat.catId),
                      ),
                    ),
                  );
                },
                child: const Text("View Incidents"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(height: 20, color: Colors.grey),
      ],
    );
  }
}
