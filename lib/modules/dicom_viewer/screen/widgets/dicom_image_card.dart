import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:medra/modules/dicom_edit/screen/dicom_viewer_screen.dart';
import '../../controller/dicom_viewer_controller.dart';
import '../../controller/reference_line_painter_controller.dart';
import '../../model/dicom_image_model.dart';

class DicomImageCard extends StatelessWidget {
  final DicomImageModel dicom;
  final bool selected;
  final double referencePos;

   DicomImageCard({
    super.key,
    required this.dicom,
    required this.selected,  this.referencePos = -1.0,
  });

  final DicomViewerController controller = DicomViewerController.instance;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              dicom.image,
              width: double.infinity,
              height: 285,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
            ),
          ),

          if (referencePos >= 0)
            IgnorePointer(
              child: CustomPaint(
                size: const Size(double.infinity, 285),
                painter: ReferenceLinePainter(slicePosition: referencePos),
              ),
            ),

          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dicom.index,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
                onTap: () {
                  Get.to(() => DicomEditScreen(dicom: dicom));
                },

                child: const Icon(Icons.edit, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
