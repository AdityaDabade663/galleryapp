import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gallery/app/data/config/cloudinary_config.dart';
import 'package:gallery/app/data/models/gallery_item_model.dart';
import 'package:gallery/app/data/repositories/firestore_gallery_repository.dart';
import 'package:gallery/app/data/repositories/gallery_repository.dart';
import 'package:gallery/app/data/repositories/mock_gallery_repository.dart';
import 'package:gallery/app/data/services/image_upload_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  late final GalleryRepository repository;
  late final ImageUploadService? uploadService;

  HomeController({
    GalleryRepository? repository,
    ImageUploadService? uploadService,
  }) {
    // 1. Resolve repository: Firestore if Firebase initialized, else fallback to mock
    if (repository != null) {
      this.repository = repository;
    } else if (Firebase.apps.isNotEmpty) {
      this.repository = FirestoreGalleryRepository();
    } else {
      this.repository = MockGalleryRepository();
    }

    // 2. Resolve upload service: Cloudinary if configured, else null
    if (uploadService != null) {
      this.uploadService = uploadService;
    } else if (CloudinaryConfig.isConfigured) {
      this.uploadService = CloudinaryUploadService(
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.uploadPreset,
      );
    } else {
      this.uploadService = null;
    }
  }

  // Navigation state
  final RxInt currentTabIndex = 0.obs;

  // Upload tab state
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final TextEditingController nameController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  // Images tab state (dynamic & realtime)
  final RxList<GalleryItemModel> images = <GalleryItemModel>[].obs;
  final RxBool isLoadingImages = true.obs;

  final ImagePicker _picker = ImagePicker();
  StreamSubscription<List<GalleryItemModel>>? _imagesSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToImages();
  }

  void _subscribeToImages() {
    isLoadingImages.value = true;
    _imagesSubscription = repository.getImagesStream().listen(
      (items) {
        images.assignAll(items);
        isLoadingImages.value = false;
      },
      onError: (error) {
        isLoadingImages.value = false;
        debugPrint('Error loading images stream: $error');
      },
    );
  }

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
  }

  Future<void> pickImageFromGallery([BuildContext? context]) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        selectedImage.value = file;
      }
    } catch (e) {
      debugPrint('Gallery access error: $e');
      if (context != null && context.mounted) {
        _showStandardSnackBar(
          context,
          'Could not access gallery: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> pickImageFromCamera([BuildContext? context]) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file != null) {
        selectedImage.value = file;
      }
    } catch (e) {
      debugPrint('Camera access error: $e');
      if (context != null && context.mounted) {
        _showStandardSnackBar(
          context,
          'Could not access camera: $e',
          isError: true,
        );
      }
    }
  }

  void clearSelectedImage() {
    if (isSubmitting.value) return; // Prevent clearing during active upload
    selectedImage.value = null;
    nameController.clear();
  }

  Future<void> submitImage(BuildContext context) async {
    // Unfocus software keyboard
    FocusScope.of(context).unfocus();

    final imageFile = selectedImage.value;
    final name = nameController.text.trim();

    // 1. Validation: Image must be selected
    if (imageFile == null) {
      _showStandardSnackBar(
        context,
        'Please select an image before submitting.',
        isWarning: true,
      );
      return;
    }

    // 2. Validation: Reference Name must not be empty
    if (name.isEmpty) {
      _showStandardSnackBar(
        context,
        'Please enter a reference name.',
        isWarning: true,
      );
      return;
    }

    // 3. Validation: Reference Name length check
    if (name.length < 2) {
      _showStandardSnackBar(
        context,
        'Reference name must be at least 2 characters long.',
        isWarning: true,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      String finalImageUrl = imageFile.path;

      // If Cloudinary upload service is configured, upload to get public URL
      if (uploadService != null) {
        try {
          finalImageUrl = await uploadService!.uploadImage(imageFile);
        } catch (uploadError) {
          debugPrint('Cloudinary upload error: $uploadError');
          if (context.mounted) {
            _showStandardSnackBar(
              context,
              'Cloudinary upload failed: $uploadError',
              isError: true,
              duration: const Duration(seconds: 4),
            );
          }
          return; // Stop here so user can retry without losing their selected image/name
        }
      }

      final newItem = GalleryItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imageUrl: finalImageUrl,
        localPath: imageFile.path,
        createdAt: DateTime.now(),
      );

      await repository.addImage(newItem);

      // Reset upload inputs
      selectedImage.value = null;
      nameController.clear();

      // Switch to images tab
      currentTabIndex.value = 1;

      if (context.mounted) {
        _showStandardSnackBar(
          context,
          'Image uploaded successfully!',
          isSuccess: true,
        );
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (context.mounted) {
        _showStandardSnackBar(
          context,
          'Upload failed: $e',
          isError: true,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteImage(BuildContext context, String id) async {
    try {
      await repository.deleteImage(id);
      if (context.mounted) {
        _showStandardSnackBar(
          context,
          'Image removed successfully.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (context.mounted) {
        _showStandardSnackBar(
          context,
          'Failed to delete image: $e',
          isError: true,
        );
      }
    }
  }

  /// Standard Flutter Material SnackBar helper (No Get.snackbar)
  void _showStandardSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor = const Color(0xFF1F2937); // Dark gray default
    if (isError) {
      backgroundColor = const Color(0xFFDC2626); // Red
    } else if (isWarning) {
      backgroundColor = const Color(0xFFD97706); // Amber / Orange
    } else if (isSuccess) {
      backgroundColor = const Color(0xFF16A34A); // Green
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void onClose() {
    _imagesSubscription?.cancel();
    nameController.dispose();
    super.onClose();
  }
}
