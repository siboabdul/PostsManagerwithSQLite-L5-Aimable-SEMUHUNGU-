import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import 'add_edit_post.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [];
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    final data = await DatabaseHelper.instance.getPosts();
    setState(() {
      posts = data;
      filteredPosts = data;
    });
  }

  void searchPosts(String query) {
    final results = posts.where((post) {
      return post.title.toLowerCase().contains(query.toLowerCase()) ||
          post.body.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPosts = results;
    });
  }

  void deletePost(int id) async {
    await DatabaseHelper.instance.deletePost(id);
    loadPosts();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deletePost(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void navigate(Post? post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditPost(post: post)),
    );
    loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Posts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: searchPosts,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredPosts.isEmpty
                ? const Center(child: Text("No posts"))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];

                      return Card(
                        child: ListTile(
                          leading: post.imagePath != null
                              ? Image.file(
                                  File(post.imagePath!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),
                          title: Text(post.title),
                          subtitle: Text("${post.body}\n${post.date}"),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(post: post),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => navigate(post),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => confirmDelete(post.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigate(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
