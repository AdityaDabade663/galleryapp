import 'package:flutter/material.dart';
import 'package:gallery/app/widgets/app_image_view.dart';
import 'package:gallery/app/widgets/dashed_rect_container.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class UploadTabView extends GetView<HomeController> {
  const UploadTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedImage = controller.selectedImage.value;
      if (selectedImage == null) {
        return _buildPickerState(context);
      } else {
        return _buildSelectedState(context, selectedImage.path);
      }
    });
  }

  // ==========================================
  // 1. Initial Picker State (Matches Mockup 1)
  // ==========================================
  Widget _buildPickerState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.85).clamp(280.0, 420.0);

    return SafeArea(
      top: true,
      bottom: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Browser Gallery Dashed Box
              DashedRectContainer(
                onTap: () => controller.pickImageFromGallery(context),
                borderColor: const Color(0xFF4ADE80),
                strokeWidth: 1.6,
                borderRadius: 16,
                dashLength: 8,
                dashGap: 6,
                child: Container(
                  width: boxWidth,
                  height: 180,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Browser Gallery',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // "OR" Divider
              SizedBox(
                width: boxWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Open Camera Dashed Box
              DashedRectContainer(
                onTap: () => controller.pickImageFromCamera(context),
                borderColor: const Color(0xFF4ADE80),
                strokeWidth: 1.6,
                borderRadius: 14,
                dashLength: 8,
                dashGap: 6,
                child: Container(
                  width: boxWidth,
                  height: 58,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Open camera',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. Selected Image State (Matches Mockup 2)
  // ==========================================
  Widget _buildSelectedState(BuildContext context, String imagePath) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // Dynamic vertical height for preview (~58% screen height)
    final previewHeight = (screenHeight * 0.58).clamp(340.0, 560.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Image Preview with Red Circular Close 'X' Button
              _buildImagePreview(imagePath, previewHeight),

              const SizedBox(height: 20),

              // Reference Name Text Field (disabled during upload to prevent edits)
              _buildReferenceNameField(),

              const SizedBox(height: 18),

              // Centered Submit Button
              _buildSubmitButton(context),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Full-width tall image preview matching Mockup 2
  Widget _buildImagePreview(String imagePath, double height) {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Image
          SizedBox(
            width: double.infinity,
            height: height,
            child: AppImageView(
              imagePath: imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // Red Circular Cross Button on top right (disabled while uploading)
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSubmitting ? null : controller.clearSelectedImage,
                borderRadius: BorderRadius.circular(20),
                child: Opacity(
                  opacity: isSubmitting ? 0.4 : 1.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Reference Name Text Field (Locked during upload)
  Widget _buildReferenceNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final isSubmitting = controller.isSubmitting.value;

        return TextField(
          controller: controller.nameController,
          enabled: !isSubmitting, // Locked when uploading
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontSize: 15,
            color: isSubmitting ? Colors.grey.shade600 : const Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Reference Name',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: isSubmitting ? Colors.grey.shade100 : Colors.white,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF16A34A),
                width: 1.6,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Centered Green Submit Button with loading state and validation
  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: Obx(() {
        final isSubmitting = controller.isSubmitting.value;
        return SizedBox(
          width: 130,
          height: 44,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => controller.submitImage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
