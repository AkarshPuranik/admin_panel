
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _announcementController = TextEditingController();
  File? _selectedImage;
  String? _selectedImageUrl; // To store the image URL for web
  bool _isUploading = false;

  Future<void> _makeAnnouncement() async {
    if (_announcementController.text.isNotEmpty || _selectedImage != null || _selectedImageUrl != null) {
      String? imageUrl = _selectedImageUrl;

      if (_selectedImage != null && !kIsWeb) {
        setState(() {
          _isUploading = true;
        });
        imageUrl = await _uploadImage(_selectedImage!);
        setState(() {
          _isUploading = false;
        });
      }

      await FirebaseFirestore.instance.collection('announcements').add({
        'content': _announcementController.text,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _announcementController.clear();
      _selectedImage = null;
      _selectedImageUrl = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement posted successfully')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: Use the URL directly
        setState(() {
          _selectedImageUrl = pickedFile.path;
        });
      } else {
        // Mobile: Use File path
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('announcement_images').child(fileName);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _announcementController,
              decoration: InputDecoration(
                labelText: 'Announcement Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // Display the image conditionally based on platform
            if (_selectedImage != null && !kIsWeb)
              Image.file(
                _selectedImage!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
            else if (_selectedImageUrl != null && kIsWeb)
              Image.network(
                _selectedImageUrl!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo),
                  label: Text('Add Image'),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _makeAnnouncement,
                  child: _isUploading
                      ? CircularProgressIndicator()
                      : Text('Post Announcement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
