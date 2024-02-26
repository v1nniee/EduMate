import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onPickImage, this.existingImage});

  final void Function(File pickedImage) onPickImage;
  final String? existingImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final ImageSource? source = await _showImageSourceDialog();

    if (source == null) return;

    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Image Source"),
          content: const Text("Where do you want to get the image from?"),
          actions: [
            TextButton(
              child: const Text("Camera"),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            TextButton(
              child: Text("Gallery"),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  ImageProvider<Object> _getImageProvider() {
    if (_pickedImageFile != null) {
      return FileImage(_pickedImageFile!);
    } else if (widget.existingImage != null) {
      if (widget.existingImage!.startsWith('http')) {
        // If the provided image string is a URL, use NetworkImage
        return NetworkImage(widget.existingImage!);
      } else {
        return AssetImage(widget.existingImage!);
      }
    } else {
      // Return a placeholder if no image is available
      return AssetImage('assets/images/tutor_seeker_profile.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 80,
          height:
              80, 
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            image: DecorationImage(
              fit: BoxFit.cover, 
              image: _getImageProvider(),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
