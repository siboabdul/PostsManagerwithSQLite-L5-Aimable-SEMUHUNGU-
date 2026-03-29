import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/post.dart';

class AddEditPost extends StatefulWidget {
  final Post? post;

  const AddEditPost({super.key, this.post});

  @override
  State<AddEditPost> createState() => _AddEditPostState();
}

class _AddEditPostState extends State<AddEditPost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  String? imagePath;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 👉 If editing, load existing data
    if (widget.post != null) {
      titleController.text = widget.post!.title;
      bodyController.text = widget.post!.body;
      imagePath = widget.post!.imagePath;
    }
  }

  // 🖼️ PICK IMAGE
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          imagePath = picked.path;
        });
      }
    } catch (e) {
      debugPrint("Image error: $e");
    }
  }

  // 💾 SAVE POST
  Future<void> savePost() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    // ✅ Validation
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Body cannot be empty")),
      );
      return;
    }

    final post = Post(
      id: widget.post?.id,
      title: title,
      body: body,
      date: DateTime.now().toString(),
      imagePath: imagePath,
    );

    try {
      if (widget.post == null) {
        await DatabaseHelper.instance.insertPost(post);
      } else {
        await DatabaseHelper.instance.updatePost(post);
      }

      // 🔥 FIX async context error
      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving post: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Post" : "Add Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📝 TITLE
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📝 BODY
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Body",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🖼️ IMAGE PREVIEW
            imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text("No Image Selected"),

            const SizedBox(height: 10),

            // 🖼️ PICK BUTTON
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Image"),
            ),

            const SizedBox(height: 20),

            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savePost,
                child: Text(isEdit ? "Update Post" : "Add Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
