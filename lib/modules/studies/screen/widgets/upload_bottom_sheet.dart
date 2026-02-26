import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../consultation/controller/consultation_controller.dart';
import '../../controller/studies_controller.dart';

class UploadBottomSheet extends StatelessWidget {
  UploadBottomSheet({super.key});

  final controller = Get.find<StudiesController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(
            () => controller.step.value == 0
            ? _stepOne()
            : _stepTwo(),
      ),
    );
  }

  // STEP 1 – DICOM UPLOAD
  Widget _stepOne() {
    final StudiesController studyController = Get.put(StudiesController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Study",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 1. Upload Box jis par click karkay file select hogi
        Obx(() => GestureDetector(
          onTap: studyController.isLoading.value
              ? null
              : () => studyController.pickAndUploadStudy(),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              border: Border.all(color: Colors.blue, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: studyController.isLoading.value
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text("Uploading DICOM ZIP...", style: TextStyle(color: Colors.blue[900])),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue),
                  const SizedBox(height: 10),
                  Text(
                    studyController.uploadedFileName.value.isEmpty
                        ? "Click to Upload DICOM Study (.zip)"
                        : "Selected: ${studyController.uploadedFileName.value}",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )),

        const Spacer(),


        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            // Agar loading ho rahi hai ya file upload nahi hui, to disable rakhein (optional)
            onPressed: (studyController.isLoading.value || studyController.uploadedFileName.value.isEmpty)
                ? null
                : () => controller.nextStep(),
            child: const Text("Next"),
          )),
        ),
      ],
    );
  }
  // STEP 2 – METADATA
  Widget _stepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          children: [
            const Text(
              "Upload study",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          ],
        ),
        const SizedBox(height: 12),

        TextFormField(

          decoration: const InputDecoration(labelText: "Patient Name",border: OutlineInputBorder()),
          // onChanged: (v) => controller.patientName.value = v,
          controller: controller.patientNameController,
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Body Part",border: OutlineInputBorder()),
          // onChanged: (v) => controller.bodyPart.value = v,
          controller: controller.bodyPartController,
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Date of Birth",border: OutlineInputBorder()),
          // onChanged: (v) => controller.studyDate.value = v,
          controller: controller.studyDateController,
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.reset();
              Get.back();
            },
            child: const Text("Upload"),
          ),
        ),
      ],
    );
  }
}







