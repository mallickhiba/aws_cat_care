import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/screens/cat/cat_screen.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/cat/cat_detail_screen.dart';
import 'package:user_repository/user_repository.dart';

class AvailableCatsPage extends StatelessWidget {
  final MyUser user;

  const AvailableCatsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: BlocBuilder<MyUserBloc, MyUserState>(
          builder: (context, state) {
            if (state.status == MyUserStatus.success &&
                state.user!.role == "admin") {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BlocProvider<CreateCatBloc>(
                        create: (context) => CreateCatBloc(
                          catRepository: FirebaseCatRepository(),
                        ),
                        child: CatScreen(state.user!),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        appBar: AppBar(
          title: const Text("Cats"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Available"),
              Tab(text: "Other Cats"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // available Cats tab
            BlocBuilder<GetCatBloc, GetCatState>(
              builder: (context, state) {
                if (state is GetCatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetCatFailure) {
                  return const Center(child: Text("Failed to load cats."));
                } else if (state is GetCatSuccess) {
                  final availableCats = state.cats
                      .where((cat) => cat.status == "Available")
                      .toList();

                  if (availableCats.isEmpty) {
                    return const Center(
                      child: Text("No cats available for adoption."),
                    );
                  }

                  return _buildCatList(context, availableCats);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),

            // other cats tab
            BlocBuilder<GetCatBloc, GetCatState>(
              builder: (context, state) {
                if (state is GetCatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetCatFailure) {
                  return const Center(child: Text("Failed to load cats."));
                } else if (state is GetCatSuccess) {
                  final otherCats = state.cats
                      .where((cat) => cat.status != "Available")
                      .toList();

                  if (otherCats.isEmpty) {
                    return const Center(
                      child: Text("No other cats."),
                    );
                  }

                  return _buildCatList(context, otherCats,
                      showAdoptButton: false);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatList(BuildContext context, List<Cat> cats,
      {bool showAdoptButton = true}) {
    return ListView.builder(
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CatDetailScreen(cat: cat, user: user),
              ),
            );
          },
          child: Padding(
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
                            image: cat.image.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(cat.image),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: cat.image.isEmpty
                              ? const Icon(Icons.pets, size: 30)
                              : null,
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
                                color: Colors.black,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.pink, size: 16),
                        Text(
                          cat.location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (showAdoptButton)
                      ElevatedButton(
                        onPressed: () {
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
          ),
        );
      },
    );
  }
}
