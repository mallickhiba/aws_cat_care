import 'package:flutter/material.dart';

class CommunityForumPage extends StatelessWidget {
  const CommunityForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
      ),
      body: ListView(
        children: const <Widget>[
          ForumPost(
            username: 'User1',
            postContent: 'This is the first post in the community forum!',
            postTime: '2 hours ago',
          ),
          ForumPost(
            username: 'User2',
            postContent: 'Hello everyone! Excited to be here.',
            postTime: '3 hours ago',
          ),
          // Add more ForumPost widgets here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add post creation functionality here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ForumPost extends StatelessWidget {
  final String username;
  final String postContent;
  final String postTime;

  const ForumPost({
    super.key,
    required this.username,
    required this.postContent,
    required this.postTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(postContent),
            const SizedBox(height: 5.0),
            Text(
              postTime,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
