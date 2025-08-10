import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:async_wallpaper/async_wallpaper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;

  /// Fungsi investigasi baru untuk izin galeri.
  Future<void> _pickImageFromGallery() async {
    print("1. Tombol ditekan. Memulai investigasi izin...");

    // Meminta kedua jenis izin sekaligus
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
    ].request();

    // Mencetak status dari setiap izin yang kita minta
    PermissionStatus? photosStatus = statuses[Permission.photos];
    PermissionStatus? storageStatus = statuses[Permission.storage];
    print("2. Status Izin FOTO (photos): $photosStatus");
    print("3. Status Izin PENYIMPANAN (storage): $storageStatus");

    // Lanjutkan jika SALAH SATU dari izin tersebut diberikan
    if (photosStatus == PermissionStatus.granted || storageStatus == PermissionStatus.granted) {
      print("4. Setidaknya satu izin DIBERIKAN. Mencoba membuka galeri...");
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      print("5. Proses pemilihan gambar dari galeri selesai.");
      if (pickedFile != null) {
        print("6. GAMBAR BERHASIL DIPILIH: ${pickedFile.path}");
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print("7. TIDAK ADA GAMBAR DIPILIH (pengguna membatalkan).");
      }
    } else {
      // Jika kedua izin ditolak
      print("8. SEMUA Izin DITOLAK. Membuka pengaturan aplikasi...");
      // Arahkan pengguna ke pengaturan jika izin ditolak secara permanen
      await openAppSettings();
    }
    print("9. Fungsi _pickImageFromGallery selesai dieksekusi.");
  }

  /// Fungsi untuk mengatur wallpaper (tidak diubah).
  Future<void> _setWallpaper() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu!')),
      );
      return;
    }
    try {
      String filePath = _selectedImage!.path;
      await AsyncWallpaper.setWallpaperFromFile(
        filePath: filePath,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper berhasil diubah!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah wallpaper: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI tidak diubah, tetap sama
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Wallpaper'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_size_select_actual_outlined,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Gambar akan tampil di sini',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Pilih dari Galeri'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectedImage == null ? null : _setWallpaper,
              icon: const Icon(Icons.wallpaper),
              label: const Text('Jadikan Wallpaper'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
