import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:aws_app/screens/incidents/cat_incidents_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'edit_cat_detail_screen.dart';

class CatDetailScreen extends StatefulWidget {
  final Cat cat;
  final MyUser user;

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
      appBar: AppBar(
        title: const Text(""),
        actions: [
          if (widget.user.role == "admin")
            IconButton(
              icon: const Icon(Icons.edit),
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

                if (updatedCat != null) {
                  setState(() {
                    cat = updatedCat;
                  });
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(cat.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                    '${cat.location}, ${cat.campus}',
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
                    // Wrap content with full-width alignment
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment:
                                WrapAlignment.start, // Align items to start
                            children: [
                              _buildBadge("${cat.age} years old"),
                              _buildBadge(cat.color),
                              _buildBadge(cat.status),
                              _buildBadge(cat.isVaccinated
                                  ? "Vaccinated"
                                  : "Not vaccinated yet"),
                              _buildBadge(
                                  cat.isHealthy ? "Healthy" : "Not Healthy"),
                              _buildBadge(
                                  cat.isFixed ? "Fixed" : "Not fixed yet"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        cat.description,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                  backgroundColor: const Color.fromARGB(255, 106, 52, 128),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("View Incidents"),
              ),
              if (cat.photos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📷 Photos",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cat.photos.length,
                        itemBuilder: (context, index) {
                          final photoUrl = cat.photos[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenPhoto(photoUrl: photoUrl),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                photoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE1BEE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class FullScreenPhoto extends StatelessWidget {
  final String photoUrl;

  const FullScreenPhoto({super.key, required this.photoUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo"),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Close on tap
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              photoUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
