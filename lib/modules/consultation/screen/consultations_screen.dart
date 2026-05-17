import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/common/widgets/appbar/appbar.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';
import 'package:medra/modules/consultation/screen/widgets/consultation_bottom_sheet.dart';
import 'package:medra/modules/consultation/screen/widgets/doctor_refer_bottom_sheet.dart';
import '../../../utills/constant/colors.dart';
import '../../dicom_viewer/screen/dicom_viewer_screen.dart';
import '../controller/consultation_controller.dart';
import 'widgets/consultation_card.dart';

class ConsultationsScreen extends StatelessWidget {
  ConsultationsScreen({super.key});

  final ConsultationController controller = Get.put(ConsultationController());
  final AuthController authcontroller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    String role = GetStorage().read('role');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RAppBar(authcontroller: authcontroller),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                role == 'doctor'
                ? const Text(
                  ' My Consultations',
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ) :
                const Text(
                  'Consultations',
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
                ,
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: RColors.primary),
                  onPressed: () {
                    String role = GetStorage().read('role') ?? 'patient';
                    if (role == 'doctor') {
                      Get.bottomSheet(
                        const DoctorReferBottomSheet(),
                        isScrollControlled: true,
                      );
                    } else {
                      Get.bottomSheet(
                        const ConsultBottomSheet(),
                        isScrollControlled: true,
                      );
                    }
                  },
                  icon: const Icon(Icons.add,color: RColors.white,),
                  label: const Text('Consult',style: TextStyle(color: RColors.white),),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              onChanged: (value) => controller.filterConsultations(value),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredConsultations.isEmpty) {
                  return const Center(child: Text("No Consultations Found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.refreshConsultations(),
                  child: ListView.builder(
                    itemCount: controller.filteredConsultations.length,
                    itemBuilder: (context, index) {
                      final consultationData = controller.filteredConsultations[index];

                      return GestureDetector(
                        onTap: () {

                          String sId = consultationData.study_id;

                          // Agar ID phir bhi null aa rahi hai to debug print karein
                          if (sId.isEmpty) {
                            print("WARNING: Study ID is empty for this consultation!");
                            // Ho sakta hai ke consultationData.id hi study ID ho?
                            // sId = consultationData.id; // Sirf testing ke liye
                          }

                          print(consultationData.study_id);
                          print(consultationData.scanType);
                          print(consultationData.patientName);
                          Get.to(() => DicomViewerScreen(), arguments: {

                            "studyId": sId,
                            "title": consultationData.scanType,
                            "patient": consultationData.patientName ?? "Patient",
                          });
                        },
                        child: ConsultationCard(
                          consultation: consultationData,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
