import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

mixin ImagePickerMixin<T extends StatefulWidget> on State<T> {
  final ImagePicker picker = ImagePicker();
  File? image;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void onTapCamera(BuildContext context) =>
      pickImage(ImageSource.camera, context);

  void onTapGallery(BuildContext context) =>
      pickImage(ImageSource.gallery, context);

  Future<void> pickImage(ImageSource imageSource, BuildContext context) async {
    final pickedFile = await picker.pickImage(source: imageSource);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadImage() async {
    if (image == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('images/$fileName');
      await ref.putFile(image!);

      final downloadURL = await ref.getDownloadURL();
      debugPrint('Image uploaded successfully. Download URL: $downloadURL');
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }
}
