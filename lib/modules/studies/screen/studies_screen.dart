import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';
import 'package:medra/modules/studies/screen/widgets/upload_bottom_sheet.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utills/constant/colors.dart';
import '../../../utills/snackbar/app_snackbar.dart';
import '../../consultation/controller/consultation_controller.dart';
import '../../dicom_viewer/screen/dicom_viewer_screen.dart';
import '../controller/studies_controller.dart';
import 'widgets/study_card.dart';

class StudiesScreen extends StatelessWidget {
  StudiesScreen({super.key});

  final StudiesController controller = Get.put(StudiesController());
  final AuthController authcontroller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    String role = GetStorage().read('role');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RAppBar(authcontroller: authcontroller,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                role == "doctor"
                ? const Text(
                  'All Studies',
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
                : const Text(
                  'My Studies',
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: RColors.primary),
                  onPressed: () {
                    Get.bottomSheet(UploadBottomSheet());
                  },
                  icon: const Icon(Icons.add,color: RColors.white,),
                  label: const Text('Upload',style: TextStyle(color: RColors.white),),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                // suffixIcon: const Icon(Icons.mic),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                    () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.studies.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.getAllStudies(),
                      // Refresh function
                      child: ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(child: Text("No Studies Available")),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.getAllStudies(),
                    color: Colors.blue,
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.studies.length,
                      itemBuilder: (context, index) {
                        final studyData = controller.studies[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => DicomViewerScreen(), arguments: {
                              "studyId": studyData.id,
                              "title": studyData.title,
                              "patient": studyData.patient_name,
                            });
                          },
                          onLongPress: () {
                            // print(studyData.id);
                            String currentUserId = controller.local.read('user_id');
                            if (currentUserId == currentUserId) {
                              _showShareBottomSheet(context, studyData.id);
                            } else {
                              AppSnackbar.error("Only the owner can share this study");
                            }
                          },
                          child: StudyCard(
                            study: studyData,
                          ),
                        );
                      },
                    ),
                  );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void _showShareBottomSheet(BuildContext context, String studyId) {
  final controller = Get.find<ConsultationController>();
  controller.loadInitialData(); // Doctors list fetch karne ke liye

  Get.bottomSheet(
    Container(
      height: 420, // Content aur spacing ke liye thori height barha di
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(() {
        bool hasDoctors = controller.doctors.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text("Share Study", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey)
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Select Doctor",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _dropdown(
              hint: hasDoctors ? "Choose recipient" : "Loading users...",
              value: controller.selectedReferDoctorId.value.isEmpty ? null : controller.selectedReferDoctorId.value,
              items: controller.doctors.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc['id'].toString(),
                  child: Text(doc['username'] ?? "No Name"),
                );
              }).toList(),
              onChanged: (val) => controller.selectedReferDoctorId.value = val ?? "",
            ),

            const SizedBox(height: 16),

            // --- Permission Level Dropdown (Backend Literal se match) ---
            const Text(
              "Permission Level",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _dropdown(
              hint: "Select Permissions",
              value: controller.selectedPermission.value,
              items: const [
                DropdownMenuItem(value: "view_only", child: Text("View Only")),
                DropdownMenuItem(value: "edit_annotations", child: Text("Allow Annotations")),
                DropdownMenuItem(value: "full_access", child: Text("Full Access")),
              ],
              onChanged: (val) => controller.selectedPermission.value = val ?? "view_only",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: RColors.primary,
                  foregroundColor: RColors.white
                ),
                onPressed: controller.selectedReferDoctorId.value.isEmpty
                    ? null
                    : () => controller.submitShareStudy(studyId),
                child: const Text("Share Now"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    ),
    isScrollControlled: true,
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
    hint: Text(hint, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    items: items,
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none
      ),
    ),
  );
}