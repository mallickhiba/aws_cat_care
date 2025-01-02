import 'package:aws_cat_care/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_cat_care/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:aws_cat_care/screens/home/adoption/available_cats_page.dart';
import 'package:aws_cat_care/screens/home/cat/cat_detail_screen.dart';
import 'package:aws_cat_care/screens/home/incidents/all_incidents_page.dart';
import 'package:aws_cat_care/screens/home/donations_page.dart';
import 'package:aws_cat_care/screens/home/cat/cat_screen.dart';
import 'package:aws_cat_care/screens/home/feeding/feeding_schedule_page.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aws_cat_care/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_cat_care/blocs/update_user_info_bloc/update_user_info_bloc.dart';
import 'package:aws_cat_care/blocs/create_cat_bloc/create_cat_bloc.dart';

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
                        ? GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxHeight: 500,
                                maxWidth: 500,
                                imageQuality: 40,
                              );
                              if (image != null) {
                                CroppedFile? croppedFile =
                                    await ImageCropper().cropImage(
                                  sourcePath: image.path,
                                  aspectRatio: const CropAspectRatio(
                                      ratioX: 1, ratioY: 1),
                                  uiSettings: [
                                    AndroidUiSettings(
                                      toolbarTitle: 'Cropper',
                                      toolbarColor:
                                          Theme.of(context).colorScheme.primary,
                                      toolbarWidgetColor: Colors.white,
                                      initAspectRatio:
                                          CropAspectRatioPreset.original,
                                      lockAspectRatio: false,
                                    ),
                                    IOSUiSettings(
                                      title: 'Cropper',
                                    ),
                                  ],
                                );
                                if (croppedFile != null) {
                                  setState(() {
                                    context.read<UpdateUserInfoBloc>().add(
                                          UploadPicture(
                                            croppedFile.path,
                                            context
                                                .read<MyUserBloc>()
                                                .state
                                                .user!
                                                .id,
                                          ),
                                        );
                                  });
                                }
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(CupertinoIcons.person,
                                  color: Colors.grey.shade400),
                            ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailableCatsPage(),
                    ),
                  );
                },
                child: const Text("View Available Cats"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedingSchedulePage(),
                    ),
                  );
                },
                child: const Text("View Feeding Schedule"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllIncidentsPage(),
                    ),
                  );
                },
                child: const Text("View All Incident Reports"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonationsPage(),
                    ),
                  );
                },
                child: const Text("View Donation Campaigns"),
              ),
            ),
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
}
