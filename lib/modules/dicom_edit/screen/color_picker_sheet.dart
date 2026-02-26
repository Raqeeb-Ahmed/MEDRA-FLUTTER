import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dicom_viewer/controller/dicom_viewer_controller.dart';
import '../controller/dicom_viewer_controller.dart';

class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DicomEditController>();

    final colors = [
      Colors.black,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.red,
      Colors.purple,
    ];

    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((c) {
              return GestureDetector(
                onTap: () {
                  controller.selectedColor.value = c ;
                  controller.addAnnotation();
                  Get.back();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Colors",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        )
      ],
    );
  }
}
