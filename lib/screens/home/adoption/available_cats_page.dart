import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';

class AvailableCatsPage extends StatelessWidget {
  const AvailableCatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cats Available for Adoption"),
      ),
      body: BlocBuilder<GetCatBloc, GetCatState>(
        builder: (context, state) {
          if (state is GetCatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetCatFailure) {
            return const Center(child: Text("Failed to load cats."));
          } else if (state is GetCatSuccess) {
            final availableCats =
                state.cats.where((cat) => !cat.isAdopted).toList();

            if (availableCats.isEmpty) {
              return const Center(
                child: Text("No cats available for adoption."),
              );
            }

            return ListView.builder(
              itemCount: availableCats.length,
              itemBuilder: (context, index) {
                final cat = availableCats[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(cat.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.catName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "Age: ${cat.age} years",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cat.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Location: ${cat.location}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Add functionality to contact for adoption
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Contact us for adoption!"),
                                ),
                              );
                            },
                            child: const Text("Adopt Me"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
