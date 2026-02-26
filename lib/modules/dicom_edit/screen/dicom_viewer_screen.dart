import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/modules/dicom_edit/screen/widgets/annotation_card.dart';
import 'package:medra/modules/dicom_edit/screen/widgets/tool_bar.dart';
import '../../dicom_viewer/model/dicom_image_model.dart';

import '../controller/dicom_viewer_controller.dart';

class DicomEditScreen extends StatelessWidget {
  final DicomImageModel dicom;

  DicomEditScreen({super.key, required this.dicom});



  @override
  Widget build(BuildContext context) {
    final DicomEditController controller = Get.put(DicomEditController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ===== Image Viewer =====
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  _dicomImage(),
                  _imageCounter(controller),

                  /// Fake overlay (for now)
                  Obx(
                        () => controller.showAnnotationInfo.value
                        ? _fakeCircleOverlay(controller)
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          // ===== Annotation Info =====
          Obx(
                () => controller.showAnnotationInfo.value
                ? AnnotationCard(
              color: controller.selectedColor.value,
              onDelete: controller.removeAnnotation,
            )
                : const SizedBox(),
          ),

          // ===== Tool Bar =====
          ToolBar(
            onColorTap: controller.openColorPicker,
            onToolSelected: controller.selectTool,
          ),
        ],
      ),
    );
  }

  // ---------------- UI Parts ----------------

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Brain CT Scan",
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            dicom.index ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        )
      ],
    );
  }

  Widget _dicomImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          dicom.image, // 🔥 image passed from DicomImageCard
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _imageCounter( DicomEditController controller) {
    return Positioned(
      top: 8,
      left: 8,
      child:  Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "04/${controller.totalImages}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
    );
  }

  Widget _fakeCircleOverlay( DicomEditController controller) {
    return Positioned(
      right: 120,
      bottom: 120,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: controller.selectedColor.value,
            width: 3,
          ),
        ),
      ),
    );
  }
}
