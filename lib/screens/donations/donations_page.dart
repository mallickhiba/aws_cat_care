import 'package:aws_app/screens/donations/create_donations_page.dart';
import 'package:aws_app/screens/other/full_screen_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  @override
  Widget build(BuildContext context) {
    final userRole = context.read<MyUserBloc>().state.user?.role ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation Campaigns"),
        actions: [
          if (userRole == "admin")
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDonationsPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading campaigns."));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No campaigns available."));
          }

          final campaigns = snapshot.data!.docs;

          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaignDoc = campaigns[index];
              final campaignData = campaignDoc.data() as Map<String, dynamic>;
              return _buildCampaignCard(campaignData, campaignDoc.id, userRole);
            },
          );
        },
      ),
    );
  }

  Widget _buildCampaignCard(
      Map<String, dynamic> campaignData, String campaignId, String userRole) {
    final title = campaignData['title'] ?? "No Title";
    final description = campaignData['description'] ?? "No Description";
    final goal = campaignData['goal'] ?? 0;
    final progress = campaignData['progress'] ?? 0;
    final images = List<String>.from(campaignData['images'] ?? []);
    final bankDetails = campaignData['bankDetails'] ?? "No Details";

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color.fromARGB(255, 239, 200, 245),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 216, 241),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (progress / goal).clamp(0.0, 1.0),
                    color: const Color.fromARGB(255, 106, 52, 128),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Text("Raised: Rs. $progress / Rs. $goal"),
                ],
              ),
            ),
            if (images.isNotEmpty)
              SizedBox(
                height: 150, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final photoUrl = images[index];
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (userRole == "admin")
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Color.fromARGB(255, 106, 52, 128)),
                      onPressed: () {
                        _navigateToEditCampaign(
                            context, campaignId, campaignData);
                      },
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _showBankDetails(context, bankDetails);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 106, 52, 128),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Donate"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankDetails(BuildContext context, String bankDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bank Details"),
          content: Text(bankDetails),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditCampaign(BuildContext context, String campaignId,
      Map<String, dynamic> campaignData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDonationsPage(
          campaignId: campaignId,
          campaignData: campaignData,
        ),
      ),
    );
  }
}

class EditDonationsPage extends StatefulWidget {
  final String campaignId;
  final Map<String, dynamic> campaignData;

  const EditDonationsPage({
    super.key,
    required this.campaignId,
    required this.campaignData,
  });

  @override
  State<EditDonationsPage> createState() => _EditDonationsPageState();
}

class _EditDonationsPageState extends State<EditDonationsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalController;
  late TextEditingController _progressController;

  late TextEditingController _bankDetailsController;
  // late int _progress;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.campaignData['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.campaignData['description'] ?? '');
    _goalController =
        TextEditingController(text: widget.campaignData['goal'].toString());
    _progressController =
        TextEditingController(text: widget.campaignData['progress'].toString());
    _bankDetailsController =
        TextEditingController(text: widget.campaignData['bankDetails'] ?? '');
  }

  Future<void> _updateCampaign() async {
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.campaignId)
        .update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'goal': int.parse(_goalController.text),
      'progress': int.parse(_progressController.text),
      'bankDetails': _bankDetailsController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: "Goal Amount",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _progressController,
              decoration: const InputDecoration(
                labelText: "Amount Raised",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bankDetailsController,
              decoration: const InputDecoration(
                labelText: "Bank Details",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateCampaign,
              child: const Text("Update Campaign"),
            ),
          ],
        ),
      ),
    );
  }
}
