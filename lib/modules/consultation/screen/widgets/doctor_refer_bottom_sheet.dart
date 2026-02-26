import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/consultation_controller.dart';

class DoctorReferBottomSheet extends StatelessWidget {
  const DoctorReferBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ConsultationController.instance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min, // Sheet ki height content ke mutabiq
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),

          // --- Dropdown 1: Doctor's Assigned Patients ---
          const Text("Select Patient", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _dropdown(
            hint: "Select Assigned Patient",
            // Doctor API se aaye huye patients ki list
            items: controller.consultations.map((c) =>
                DropdownMenuItem(value: c.id, child: Text("${c.doctorName} (${c.scanType})"))
            ).toList(),
            onChanged: (val) => controller.selectedConsultationId.value = val!,
          ),

          const SizedBox(height: 16),

          // --- Dropdown 2: All Available Doctors ---
          const Text("Recommend Doctor", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _dropdown(
            hint: "Select Doctor",
            items: controller.doctors.map((doc) =>
                DropdownMenuItem(value: doc['id'].toString(), child: Text(doc['username'] ?? "No Name"))
            ).toList(),
            onChanged: (val) => controller.selectedReferDoctorId.value = val!,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => controller.submitReferral(),
              child: const Text("Consult", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      )),
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

  Widget _dropdown({required String hint, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
    );
  }
}