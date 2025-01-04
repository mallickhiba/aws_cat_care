import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:aws_app/screens/home/adoption/available_cats_page.dart';
import 'package:aws_app/screens/home/cat/cat_detail_screen.dart';
import 'package:aws_app/screens/home/incidents/all_incidents_page.dart';
import 'package:aws_app/screens/home/products_page.dart';
import 'package:aws_app/screens/home/donations_page.dart';
import 'package:aws_app/screens/home/cat/cat_screen.dart';
import 'package:aws_app/screens/home/feeding/feeding_schedule_page.dart';
import 'package:aws_app/screens/home/user_duties_page.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';

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
        floatingActionButton: BlocBuilder<MyUserBloc, MyUserState>(
          builder: (context, state) {
            if (state.status == MyUserStatus.success &&
                state.user!.role == "admin") {
              // Show the "Add Cat" button only for admin users
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
                child: const Icon(CupertinoIcons.add),
              );
            } else {
              // Hide the button for non-admin users
              return const SizedBox.shrink();
            }
          },
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
                    state.user!.picture == ""
                        ? Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.person,
                                color: Colors.grey.shade400),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  state.user!.picture!,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    const SizedBox(width: 10),
                    Text("Welcome ${state.user!.name}")
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(const SignOutRequired());
              },
              icon: Icon(
                CupertinoIcons.square_arrow_right,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            _buildCardButton(context, "View Available Cats", Icons.pets,
                const AvailableCatsPage()),
            _buildCardButton(context, "View Feeding Schedule", Icons.schedule,
                const FeedingSchedulePage()),
            _buildCardButton(context, "View All Incident Reports",
                Icons.report_problem, const AllIncidentsPage()),
            _buildCardButton(context, "View Donation Campaigns",
                Icons.volunteer_activism, const DonationsPage()),
            _buildCardButton(context, "View Your Duties", Icons.assignment_ind,
                const UserDutiesPage()),
            _buildCardButton(context, "View Products", Icons.shopping_bag,
                const ProductsPage()),
            Expanded(
              child: BlocBuilder<GetCatBloc, GetCatState>(
                builder: (context, state) {
                  if (state is GetCatSuccess) {
                    return ListView.builder(
                      itemCount: state.cats.length,
                      itemBuilder: (context, index) {
                        final cat = state.cats[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider<UpdateCatBloc>(
                                  create: (context) => UpdateCatBloc(
                                    catRepository: FirebaseCatRepository(),
                                  ),
                                  child: CatDetailScreen(
                                    cat: cat,
                                    user: context
                                        .read<MyUserBloc>()
                                        .state
                                        .user!, // Pass the user here
                                  ),
                                ),
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
                                            image: DecorationImage(
                                              image: NetworkImage(cat.image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Location: ${cat.location}",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        Text(
                                          cat.isAdopted
                                              ? "Adopted"
                                              : "Available",
                                          style: TextStyle(
                                            color: cat.isAdopted
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is GetCatFailure) {
                    return const Center(
                      child: Text("An error has occurred"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [brand, brand.withAlpha(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
