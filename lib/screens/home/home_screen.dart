import 'package:aws_app/blocs/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:aws_app/screens/home/cat/cat_screen.dart';
import 'package:aws_app/screens/home/incidents/report_incident_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/home/cat/cat_detail_screen.dart';
import 'package:aws_app/screens/home/adoption/available_cats_page.dart';
import 'package:aws_app/screens/home/products_page.dart';
import 'package:aws_app/screens/home/feeding/feeding_schedule_page.dart';
import 'package:aws_app/screens/home/donations_page.dart';
import 'package:aws_app/screens/home/user_duties_page.dart';
import 'package:aws_app/screens/home/incidents/all_incidents_page.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';
import 'package:cat_repository/cat_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateUserInfoBloc, UpdateUserInfoState>(
      listener: (context, state) {
        if (state is UploadPictureSuccess) {
          setState(() {
            context.read<MyUserBloc>().state.user!.picture = state.userImage;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ReportIncidentPage(), // Replace with your actual page
              ),
            );
          },
          label: const Text(
            'Report an Incident',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.report_problem, color: Colors.white),
          backgroundColor: Theme.of(context)
              .primaryColor, // Use theme color or a custom color
        ),
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, state) {
              if (state.status == MyUserStatus.success) {
                return Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "Welcome ${state.user!.name}!",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
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
          child: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, state) {
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
                    _buildCardButton(context, "Feeding Schedule",
                        Icons.schedule, const FeedingSchedulePage()),
                    _buildCardButton(context, "Incident Reports",
                        Icons.report_problem, const AllIncidentsPage()),
                    _buildCardButton(context, "Donate",
                        Icons.volunteer_activism, const DonationsPage()),
                    _buildCardButton(context, "Volunteer Duties",
                        Icons.assignment_ind, const UserDutiesPage()),
                    _buildCardButton(context, "Products", Icons.shopping_bag,
                        const ProductsPage()),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
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
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
