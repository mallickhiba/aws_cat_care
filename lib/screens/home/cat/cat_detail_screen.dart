import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:aws_app/screens/home/incidents/cat_incidents_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'edit_cat_detail_screen.dart'; // Import the edit screen

class CatDetailScreen extends StatefulWidget {
  final Cat cat;
  final MyUser user; // Pass the user object to check the role

  const CatDetailScreen({super.key, required this.cat, required this.user});

  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  late Cat cat;

  @override
  void initState() {
    super.initState();
    cat = widget.cat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        title: const Text("Cat Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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

            // Cat Name and Location
            Text(
              cat.catName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_pin, color: Colors.pink),
                Text(
                  cat.location,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🐾 About ${cat.catName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info Badges
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildBadge("Age", cat.age.toString()),
                      _buildBadge("Adopted", cat.isAdopted ? "Yes" : "No"),
                      _buildBadge("Fixed", cat.isFixed ? "Yes" : "No"),
                      _buildBadge("Color", cat.color),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    cat.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("View Incidents"),
            ),

            // Edit Button for Admin Users
            if (widget.user.role == "admin")
              ElevatedButton(
                onPressed: () async {
                  final updatedCat = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => UpdateCatBloc(
                          catRepository: FirebaseCatRepository(),
                        ),
                        child: EditCatDetailScreen(cat: cat),
                      ),
                    ),
                  );

                  // Refresh details if updatedCat is returned
                  if (updatedCat != null) {
                    setState(() {
                      cat = updatedCat;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Edit Cat Details"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE1BEE7), // Light purple
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
