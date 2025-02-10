import 'package:aws_app/screens/incidents/report_incident_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/screens/adoption/available_cats_page.dart';
import 'package:aws_app/screens/other/products_page.dart';
import 'package:aws_app/screens/feeding/feeding_schedule_page.dart';
import 'package:aws_app/screens/donations/donations_page.dart';
import 'package:aws_app/screens/other/user_duties_page.dart';
import 'package:aws_app/screens/incidents/all_incidents_page.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/other/full_screen_photo.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetCatBloc>().add(GetCats()); // Fetch all cats on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportIncidentPage(),
            ),
          );
        },
        label: const Text(
          '', //REPORT AN INCIDENT
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'ICEBOLD',
          ),
        ),
        icon: const Icon(Icons.report_problem, color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: BlocBuilder<MyUserBloc, MyUserState>(
          builder: (context, state) {
            debugPrint('MyUserBloc state: $state');
            if (state.status == MyUserStatus.success) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Spacing above "Welcome" text
                  Text(
                    "Welcome ${state.user!.name}!",
                    style: const TextStyle(
                      fontSize: 30,
                      fontFamily: 'ICEBOLD',
                      color: Color.fromARGB(255, 106, 52, 128),
                    ),
                  ),
                ],
              );
            } else if (state.status == MyUserStatus.failure) {
              return const Text("Error loading user!");
            } else {
              return const Text("Loading...");
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SignInBloc>().add(const SignOutRequired());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 5, // To ensure more space for buttons
              child: BlocBuilder<MyUserBloc, MyUserState>(
                builder: (context, state) {
                  debugPrint('MyUserBloc body state: $state');
                  if (state.status == MyUserStatus.success) {
                    final user = state.user!;
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: 2,
                      mainAxisSpacing: 10.0,
                      children: [
                        _buildCardButton(context, "Cats", Icons.pets,
                            AvailableCatsPage(user: user)),
                        _buildCardButton(context, "Schedule", Icons.schedule,
                            const FeedingSchedulePage()),
                        _buildCardButton(context, "Incidents",
                            Icons.report_problem, const AllIncidentsPage()),
                        _buildCardButton(context, "Donate",
                            Icons.volunteer_activism, const DonationsPage()),
                        _buildCardButton(context, "Duties",
                            Icons.assignment_ind, const UserDutiesPage()),
                        _buildCardButton(context, "Supplies",
                            Icons.shopping_bag, const ProductsPage()),
                      ],
                    );
                  } else if (state.status == MyUserStatus.failure) {
                    return const Center(
                      child:
                          Text("Failed to load data. Please try again later."),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Latest Cats!",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'ICEBOLD',
                  color: Color.fromARGB(255, 106, 52, 128),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 4, // To ensure enough space for latest cats
              child: BlocBuilder<GetCatBloc, GetCatState>(
                builder: (context, state) {
                  if (state is GetCatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetCatFailure) {
                    return const Center(
                      child: Text("Failed to load cat photos."),
                    );
                  } else if (state is GetCatSuccess) {
                    final photos = state.cats
                        .expand((cat) => cat.photos)
                        .toList()
                      ..sort((a, b) => b.compareTo(a)); // Sort by latest first

                    if (photos.isEmpty) {
                      return const Center(
                        child: Text("No photos available."),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photoUrl = photos[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenPhoto(
                                  photoUrl: photoUrl,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(
      BuildContext context, String title, IconData icon, Widget page) {
    Color brand = const Color.fromARGB(255, 106, 52, 128);
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [brand, brand.withAlpha(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'ICEBOLD',
                  )),
            )
          ],
        ),
      ),
    );
  }
}
