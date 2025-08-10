import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:async_wallpaper/async_wallpaper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box _settingsBox;
  List<String> _imageList = [];

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('wallpaper_settings');
    _loadImageList();
  }

  void _loadImageList() {
    final data = _settingsBox.get('image_list', defaultValue: <String>[]);
    setState(() {
      _imageList = List<String>.from(data);
    });
  }

  Future<void> _saveImageList() async {
    await _settingsBox.put('image_list', _imageList);
  }

  Future<void> _pickAndCropImages() async {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    Map<Permission, PermissionStatus> statuses =
        await [Permission.photos, Permission.storage].request();

    if (statuses[Permission.photos] == PermissionStatus.granted ||
        statuses[Permission.storage] == PermissionStatus.granted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty && mounted) {
        List<String> newImages = [];
        for (var file in pickedFiles) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            aspectRatio: CropAspectRatio(
                ratioX: screenSize.width, ratioY: screenSize.height),
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Adjust to Screen',
                  toolbarColor: theme.primaryColor,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: true),
            ],
          );
          if (croppedFile != null) {
            newImages.add(croppedFile.path);
          }
        }

        if (newImages.isNotEmpty) {
          setState(() {
            for (var path in newImages) {
              if (!_imageList.contains(path)) {
                _imageList.add(path);
              }
            }
          });
          await _saveImageList();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('${newImages.length} images cropped & saved!')),
            );
          }
        }
      }
    } else {
      await openAppSettings();
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageList.removeAt(index);
    });
    _saveImageList();
  }

  Future<void> _setWallpaper(String imagePath) async {
    try {
      await AsyncWallpaper.setWallpaperFromFile(
        filePath: imagePath,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper set successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set wallpaper: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            onPressed: _pickAndCropImages, // <-- This was missing
            tooltip: 'Add & Crop Image',
          ),
        ],
      ),
      body: _imageList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your collection is empty.\nPress + to add images.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: _imageList.length,
              itemBuilder: (context, index) {
                final imagePath = _imageList[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      title: Text(
                        'Image ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.wallpaper_rounded),
                        color: Colors.white,
                        onPressed: () => _setWallpaper(imagePath),
                        tooltip: 'Set as Wallpaper',
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
