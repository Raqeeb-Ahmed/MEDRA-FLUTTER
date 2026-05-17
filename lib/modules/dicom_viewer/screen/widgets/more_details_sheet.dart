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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            children: [
              // Modal Handle & Header
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      /// 1. Study Details Card
                      _buildStudyDetailsCard(),

                      const SizedBox(height: 16),

                      /// 2. AI Analysis Toggle Card
                      _buildToggleCard(
                        title: "AI Analysis",
                        subtitle: "Enable AI Analysis",
                        icon: Icons.psychology_outlined,
                        value: controller.aiEnabled,
                        onChanged: (val) => controller.toggleAI(val),
                      ),

                      const SizedBox(height: 16),

                      /// 3. Annotations Section (Dynamic List)
                      _buildAnnotationsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header with X button
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text("More Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Exact Match: Study Details Card
  Widget _buildStudyDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Study details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _studyInfoText("Brain CT Scan"),
          _studyInfoText("Ali"),
          _studyInfoText("Ali@gmail.com"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _studyInfoText("06-04-2025"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: const Text("AI Analysed", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Generic Toggle Card for AI/Annotations
  Widget _buildToggleCard({required String title, required String subtitle, required IconData icon, required RxBool value, required Function(bool) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Obx(() => Switch(
                value: value.value,
                onChanged: onChanged,
                activeColor: Colors.green,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Annotations List Section
  Widget _buildAnnotationsSection() {
    return Column(
      children: [
        // Using static data to match image UI but ready for dynamic
        _buildToggleCard(
          title: "Annotations (1)",
          subtitle: "", // Optional subtitle
          icon: Icons.edit_note_rounded,
          value: true.obs, // Connect to controller.showAnnotations
          onChanged: (v) {},
        ),
        const SizedBox(height: 10),

        // Specific Annotation Item from Image
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(6)),
                    child: const Text("Mark", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Small Abnormality", style: TextStyle(color: Colors.grey)),
              const Text("Non Cancerous Growth", style: TextStyle(color: Colors.grey)),
              const Text("Dr Raqeeb", style: TextStyle(color: Colors.grey)),
              const Text("08-04-2025", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper styles
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
  );

  Widget _studyInfoText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
  );
}