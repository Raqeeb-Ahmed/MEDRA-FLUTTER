import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/consultation_controller.dart';

class ConsultBottomSheet extends StatelessWidget {
  const ConsultBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ConsultationController controller = ConsultationController.instance;

    return Container(
      height: 380,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(() {

        bool hasDoctors = controller.doctors.isNotEmpty;
        bool hasStudies = controller.studies.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),

            const Text(
              "Dicom Study",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _dropdown(
              hint: hasStudies ? "Select Study" : "Loading studies...",
              value: controller.selectedStudyId.value.isEmpty ? null : controller.selectedStudyId.value,
              items: controller.studies.map((study) {
                return DropdownMenuItem<String>(
                  value: study.id.toString(),
                  child: Text(study.title),
                );
              }).toList(),
              onChanged: (val) => controller.selectedStudyId.value = val ?? "",
            ),

            const SizedBox(height: 16),
            const Text(
              "Select Doctor",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _dropdown(
              hint: hasDoctors ? "Select Doctor" : "Loading doctors...",
              value: controller.selectedDoctorId.value.isEmpty ? null : controller.selectedDoctorId.value,
              items: controller.doctors.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc['id'].toString(),
                  child: Text(doc['username'] ?? "No Name"),
                );
              }).toList(),
              onChanged: (val) => controller.selectedDoctorId.value = val ?? "",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (controller.selectedDoctorId.value.isEmpty || controller.selectedStudyId.value.isEmpty)
                    ? null
                    : () => controller.submitConsultation(),
                child: const Text("Consult"),
              ),
            ),
          ],
        );
      }),
    );
  }














  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        const Text("Consult Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _dropdown({
    required String hint,
    String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}