import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/modules/dicom_viewer/controller/dicom_viewer_controller.dart';

import '../../../../utills/snackbar/app_snackbar.dart';
import '../../../dicom_edit/controller/dicom_edit_controller.dart';
import '../../../dicom_edit/screen/dicom_edit_screen.dart';
import '../../../dicom_edit/screen/widgets/annotation_card.dart';

class AnnotationDetailsSheet extends StatelessWidget {
  const AnnotationDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DicomViewerController>();
    final editcontroller = DicomEditController.instance;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
              // Modal Notch and Header
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      /// 1. DICOM Image Preview (As seen in AnnotationDetails)
                      _buildImagePreview(controller),

                      const SizedBox(height: 16),

                      /// 2. Study Details Card
                      // _buildStudyDetailsCard(),

                      const SizedBox(height: 16),

                      /// 3. AI Analysis Toggle (As seen in More1.png)
                      Obx(
                        () => _buildToggleCard(
                          title: "AI Analysis",
                          subtitle: "Enable AI Analysis",
                          icon: Icons.psychology_outlined,
                          value: controller.aiEnabled.value,
                          onChanged: controller.toggleAI,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// --- NEW SEARCH BAR ---
                      _buildSearchBar(editcontroller),

                      const SizedBox(height: 16),

                      /// 4. Annotations Section
                      _buildAnnotationsSection(),

                      const SizedBox(height: 30),
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

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text(
                "More Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildImagePreview(DicomViewerController controller) {
  //   return Container(
  //     height: 250,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.black,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.blueAccent, width: 2),
  //     ),
  //     child: Stack(
  //       children: [
  //         const Center(
  //           child: Icon(
  //             Icons.image,
  //             color: Colors.white24,
  //             size: 50,
  //           ), // Replace with actual image
  //         ),
  //         Positioned(
  //           top: 10,
  //           left: 12,
  //           child: Text(
  //             "01/20",
  //             style: TextStyle(color: Colors.white, fontSize: 12),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStudyDetailsCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: _cardDecoration(),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Study details",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         const SizedBox(height: 12),
  //         _infoRow("Brain CT Scan"),
  //         _infoRow("Ali"),
  //         _infoRow("Ali@gmail.com"),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             _infoRow("06-04-2025"),
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 10,
  //                 vertical: 4,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Text(
  //                 "Pending AI Analysed",
  //                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.greenAccent[700],
          ),
        ],
      ),
    );
  }

  // Widget _buildAnnotationsSection(DicomViewerController controller) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: _cardDecoration(),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 const Icon(Icons.edit_note),
  //                 const SizedBox(width: 8),
  //                 const Text(
  //                   "Annotations (1)",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //             // MoreDetailsSheet.dart mein annotations section ka switch
  //             Obx(() => Switch(
  //               value: controller.showAnnotations.value,
  //               onChanged: (v) => controller.toggleAnnotations(v),
  //               activeColor: Colors.green,
  //             )),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //
  //         // Annotation Item Card
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(15),
  //             border: Border.all(color: Colors.grey[300]!),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons.arrow_upward,
  //                         color: Colors.green,
  //                         size: 18,
  //                       ),
  //                       const SizedBox(width: 6),
  //                       _badge("Mark"),
  //                     ],
  //                   ),
  //                   const Icon(
  //                     Icons.delete_outline,
  //                     color: Colors.red,
  //                     size: 20,
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 8),
  //               const Text(
  //                 "Small Abnormality",
  //                 style: TextStyle(color: Colors.grey, fontSize: 14),
  //               ),
  //               const Text(
  //                 "Non Cancerous Growth",
  //                 style: TextStyle(color: Colors.grey, fontSize: 14),
  //               ),
  //               const Text(
  //                 "Dr Raqeeb",
  //                 style: TextStyle(color: Colors.grey, fontSize: 14),
  //               ),
  //               const Text(
  //                 "08-04-2025",
  //                 style: TextStyle(color: Colors.grey, fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  // MoreDetailsSheet.dart ke andar Image Preview section:
  Widget _buildImagePreview(DicomViewerController controller) {
    final dicom = controller.selectedDicomForDetails.value;
    if (dicom == null) return const SizedBox();

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              // Wahi URL logic jo DicomImageCard mein use ki thi
              controller.constructFullUrl(dicom.image),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 10, left: 12,
            child: Text("${dicom.index}", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// // Annotations Section (Real Data from Controller)
//   Widget _buildAnnotationsSection(DicomViewerController controller) {
//     // Safe way to filter: check if annotations is not null
//     final selectedId = controller.selectedDicomForDetails.value?.id;
//
//     // List ko filter karne ka mahfooz tareeqa
//     final currentAnnotations = controller.annotations.where((a) {
//       return a != null && a['slice_id'] == selectedId;
//     }).toList();
//
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Dynamic length show karein
//             Text("Annotations (${currentAnnotations.length})",
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             Obx(() => Switch(
//               value: controller.showAnnotations.value,
//               onChanged: (v) => controller.showAnnotations.value = v,
//               activeColor: Colors.green,
//             )),
//           ],
//         ),
//         const SizedBox(height: 12),
//
//         // Agar annotations nahi hain to message dikhayein
//         if (currentAnnotations.isEmpty)
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text("No annotations for this slice", style: TextStyle(color: Colors.grey)),
//           )
//         else
//           ...currentAnnotations.map((data) => _buildAnnotationItem(data)).toList(),
//       ],
//     );
//   }
//


  Widget _buildAnnotationsSection() {
    final editController = Get.find<DicomEditController>();
    editController.fetchAllStudyAnnotations();

    return Obx(() {
      // AB YE REFRESH HOGA JAB SEARCH QUERY BADLE GI
      final displayList = editController.filteredAllStudyAnnotations;
      final bool isVisible = editController.showAnnotations.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Full Study Annotations (${isVisible ? displayList.length : 0})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Switch(
                value: isVisible,
                onChanged: (v) => editController.showAnnotations.value = v,
                activeColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (editController.isLoading.value)
            const Center(child: CircularProgressIndicator())
          else if (!isVisible)
            const Text("Annotations hidden")
          else if (displayList.isEmpty)
              const Text("No matching annotations found")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final data = displayList[index];
                  return GestureDetector(
                    onTap: () {
                      final String annotationSliceId = (data['slice_id'] ?? data['image_id'] ?? "").toString().trim();
                      print("DEBUG: Clicking on Annotation with ID: $annotationSliceId");

                      final controller = Get.find<DicomViewerController>();
                      if (annotationSliceId.isEmpty) {
                        AppSnackbar.error("Annotation ID missing");
                        return;
                      }

                     var targetList = (controller.activeSlot.value == 1)
                          ? controller.slot1Images
                          : controller.slot2Images;

                      int targetIndex = targetList.indexWhere((img) {
                        return img.id.toString().trim() == annotationSliceId;
                      });

                      if (targetIndex != -1) {
                        print("Target Index Found: $targetIndex. Opening Edit Screen now...");
                        Get.back(); // Sheet band karein

                        editController.setupEditScreenData(
                            targetList,
                            targetIndex,
                            controller.currentStudyId ?? ""
                        );

                        Get.to(() => DicomEditScreen());

                      } else {
                        print("DEBUG: Match failed.");
                        AppSnackbar.error("Slice current folder mein nahi mili");
                      }
                    },
                    child: AnnotationCard(
                      annotation: data,
                      onDelete: () => editController.removeAnnotation(data['id'], index),
                    ),
                  );
                },
              ),
        ],
      );
    });
  }



  Widget _buildAnnotationItem(dynamic data, DicomViewerController controller) {
    // 1. Data normalize karein
    final bool isSaved = data.containsKey('coordinates_json');
    final Map<String, dynamic> coords = isSaved
        ? (data['coordinates_json'] is String ? jsonDecode(data['coordinates_json']) : data['coordinates_json'])
        : data;

    // 2. Keys ko carefully pick karein
    String role = (data['role'] ?? coords['role'] ?? "User").toString(); // [cite: 5]
    String tool = (data['tool_type'] ?? coords['tool'] ?? "None").toString();
    String comment = (coords['comment'] ?? "No comment").toString();
    String sliceId = (data['slice_id'] ?? "Unknown").toString();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(_getToolIcon(tool), size: 20, color: Colors.blue),
      ),
      title: Text(comment, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Role: $role | Slice: $sliceId"), // Role ab sahi aayega
      trailing: Text(tool.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      onTap: () => controller.jumpToEditScreen(data), //
    );
  }



// Search Bar ko Edit Controller se connect karein
  Widget _buildSearchBar(DicomEditController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value.trim(),
        decoration: InputDecoration(
          hintText: "Search by comment, role or tool...",
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.blue),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.searchQuery.value = "",
          )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }

  // Widget _buildAnnotationItem(Map<String, dynamic> data) {
  //   final coords = data['coordinates_json'] ?? {};
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 10),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: Colors.grey[300]!),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               children: [
  //                 const Icon(Icons.arrow_upward, color: Colors.green, size: 18),
  //                 const SizedBox(width: 6),
  //                 _badge(data['tool_type'] ?? "Mark"),
  //               ],
  //             ),
  //             const Icon(Icons.delete_outline, color: Colors.red, size: 20),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(coords['comment'] ?? "No description", style: const TextStyle(color: Colors.grey)),
  //         Text(data['role'] ?? "User", style: const TextStyle(color: Colors.grey)),
  //         Text(data['created_at'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
  //       ],
  //     ),
  //   );
  // }



  IconData _getToolIcon(String tool) {
    if (tool.contains("circle")) return Icons.circle_outlined;
    if (tool.contains("square") || tool.contains("rect")) return Icons.crop_square;
    return Icons.edit;
  }


  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // Widget _buildSearchBar(DicomViewerController controller) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade300),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
  //       ],
  //     ),
  //     child: TextField(
  //       // Trim use karein taake faltu spaces masla na karein
  //       onChanged: (value) => controller.searchQuery.value = value.trim(),
  //       decoration: InputDecoration(
  //         hintText: "Search by comment, role or tool...",
  //         hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
  //         border: InputBorder.none,
  //         icon: const Icon(Icons.search, color: Colors.blue),
  //         // Clear button agar search query likhi ho
  //         suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
  //             ? IconButton(
  //           icon: const Icon(Icons.close, size: 20),
  //           onPressed: () => controller.searchQuery.value = "",
  //         )
  //             : const SizedBox.shrink()),
  //       ),
  //     ),
  //   );
  // }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _infoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }












}



// Search Bar Widget

// Updated Annotations Section (Toggle and Search Logic)
