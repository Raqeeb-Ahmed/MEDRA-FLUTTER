import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/modules/dicom_viewer/controller/dicom_viewer_controller.dart';

class MoreDetailsSheet extends StatelessWidget {
  const MoreDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DicomViewerController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Center(
                  child: Text("More Details",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                /// Study Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Study details",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Brain CT Scan"),
                        Text("Atif Khan"),
                        Text("example@gmail.com"),
                        Text("06-04-2025"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// AI Toggle
                Obx(() => SwitchListTile(
                  title: const Text("AI Analysis"),
                  value: controller.aiEnabled.value,
                  onChanged: controller.toggleAI,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}