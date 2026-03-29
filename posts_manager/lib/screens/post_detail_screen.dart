import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (post.imagePath != null) Image.file(File(post.imagePath!)),
            Text(post.title, style: const TextStyle(fontSize: 20)),
            Text(post.body),
            Text(post.date),
          ],
        ),
      ),
    );
  }
}
