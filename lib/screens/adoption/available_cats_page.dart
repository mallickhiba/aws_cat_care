import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/screens/cat/cat_screen.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/cat/cat_detail_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cat Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        image: cat.image.isNotEmpty
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(cat.image),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey.shade300,
                      ),
                      child: cat.image.isEmpty
                          ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                          : null,
                    ),

                    const SizedBox(width: 16),
                    // Cat Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.catName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${cat.age} years old",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_pin,
                                  color: Colors.pink, size: 16),
                              Expanded(
                                child: Text(
                                  cat.location,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Text(
                          //   cat.description,
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: const TextStyle(fontSize: 14),
                          // ),
                        ],
                      ),
                    ),
                    // Adopt Button
                    if (showAdoptButton)
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Contact us for adoption!"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 106, 52, 128),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
                          child: const Text("Adopt me!"),
                        ),
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
