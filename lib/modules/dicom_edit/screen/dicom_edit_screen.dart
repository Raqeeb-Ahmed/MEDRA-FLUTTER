import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/modules/dicom_edit/screen/widgets/annotation_card.dart';
import 'package:medra/modules/dicom_edit/screen/widgets/tool_bar.dart';

import '../../../utills/snackbar/app_snackbar.dart';
import '../../dicom_viewer/model/dicom_image_model.dart';
import '../controller/annotation_painter.dart';
import '../controller/dicom_edit_controller.dart';
import 'color_picker_sheet.dart';

class DicomEditScreen extends StatelessWidget {
  // final DicomImageModel dicom;
  DicomEditScreen({super.key,
    // required this.dicom
  });

  @override
  Widget build(BuildContext context) {
    final DicomEditController controller = Get.isRegistered<DicomEditController>()
        ? Get.find<DicomEditController>()
        : Get.put(DicomEditController());
    // Screen load hote hi purani annotations mangwa lein
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (dicom.study_id.isNotEmpty && dicom.id.isNotEmpty) {
    //     controller.fetchSavedAnnotations(dicom.study_id, dicom.id);
    //   }
    // });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.initializeFallback(dicom);
    // });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(
        controller
      ),
      body: Column(
        children: [



          Obx(() => controller.isLoading.value
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _buildImageViewer(controller)),

          const SizedBox(height: 8),

          // Range Info Logic (Jab bulk save on ho)
          _buildRangeInfo(controller),

          // SLIDER YAHAN HAI
          _buildCustomSlider(controller),


          const SizedBox(height: 12),

          // ===== Annotation Detail Card =====
          // Obx(() => controller.annotations.isNotEmpty
          //     ? AnnotationCard(
          //   color: controller.selectedColor.value,
          //   onDelete: () => controller.annotations.clear(),
          // )
          //     : const SizedBox()),

          // Annotation Detail Card
          Obx(() => controller.annotations.isNotEmpty
              ? SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: controller.annotations.length,
              itemBuilder: (context, index) {
                final data = controller.annotations[index];
                return AnnotationCard(
                  annotation: data,
                  onDelete: () {
                    print("Annotaion removed ${data['id']}");
                    controller.removeAnnotation(data['id']?.toString(), index);
                  },
                );
              },
            ),
          )
              : const SizedBox()),
          ToolBar(
            onColorTap: () => Get.bottomSheet(const ColorPickerSheet()),
            onToolSelected: controller.selectTool,
          ),


        ],
      ),
    );
  }

  Widget _buildCustomSlider(DicomEditController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Slow / Previous
          IconButton(
            onPressed: () {
              int currentIndex = controller.currentImageIndex.value - 1; // 0-based
              if (currentIndex > 0) {
                controller.onSliceChanged(currentIndex - 1);
              }
            },
            icon: const Icon(Icons.fast_rewind, color: Colors.blue),
            tooltip: "Slow / Previous",
          ),

          // SLIDER (Middle)
          Expanded(
            child: Obx(() {
              int total = controller.totalImages.value;
              double maxVal = total > 0 ? (total - 1).toDouble() : 0.0;
              double currentVal = (controller.currentImageIndex.value - 1).toDouble().clamp(0.0, maxVal);

              return Slider(
                value: currentVal,
                min: 0,
                max: maxVal,
                activeColor: controller.isRangeMode.value ? Colors.blue : Colors.blueAccent,
                onChanged: (value) => controller.onSliceChanged(value.toInt()),
              );
            }),
          ),

          // Fast / Next
          IconButton(
            onPressed: () {
              int currentIndex = controller.currentImageIndex.value - 1; // 0-based
              if (currentIndex < controller.totalImages.value - 1) {
                controller.onSliceChanged(currentIndex + 1);
              }
            },
            icon: const Icon(Icons.fast_forward, color: Colors.blue),
            tooltip: "Fast / Next",
          ),
        ],
      ),
    );
  }



  //  Image Viewer Widget
  // Widget _buildImageViewer(DicomEditController controller) {
  //   return Expanded(
  //     flex: 5,
  //     child: LayoutBuilder(
  //       builder: (context, constraints) {
  //         return Obx(() {
  //           if (controller.editImages.isEmpty) return const SizedBox();
  //
  //           // Slider ke mutabiq slice display karega (initialIndex wala slice)
  //           final currentDicom = controller.editImages[controller.currentImageIndex.value - 1];
  //
  //           return GestureDetector(
  //             onTapUp: (details) {
  //               if (controller.currentStudyId.value.isEmpty) {
  //                 AppSnackbar.error("Critical Error: Missing Study ID");
  //                 return;
  //               }
  //               controller.handleImageTap(details.localPosition, controller.currentStudyId.value, currentDicom.id.toString());
  //             },
  //             child: Container(
  //               width: constraints.maxWidth,
  //               height: constraints.maxHeight,
  //               color: Colors.black,
  //               child: Stack(
  //                 alignment: Alignment.center,
  //                 children: [
  //                   // 1. Image Layer
  //                   Positioned.fill(child: _dicomImageWidget(currentDicom.image, controller)),
  //
  //                   // 2. Drawing Layer
  //                   // CustomPaint(
  //                   //   size: Size(constraints.maxWidth, constraints.maxHeight),
  //                   //   painter: AnnotationPainter(controller.annotations.toList()),
  //                   // ),
  //
  //                   // NAYA CODE:
  //                   Obx(() {
  //                     // Agar showAnnotations false hai, toh drawing mat dikhao
  //                     if (!controller.showAnnotations.value) {
  //                       return const SizedBox.shrink(); // Bilkul khali widget return kar dega
  //                     }
  //
  //                     // Agar true hai, toh saari drawings dikhao
  //                     return CustomPaint(
  //                       size: Size(constraints.maxWidth, constraints.maxHeight),
  //                       painter: AnnotationPainter(controller.annotations.toList()),
  //                     );
  //                   }),
  //
  //                   // 3. Slice Counter
  //                   _imageCounter("${controller.currentImageIndex.value} / ${controller.totalImages.value}"),
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //       },
  //     ),
  //   );
  // }


  Widget _buildImageViewer(DicomEditController controller) {
    return Expanded(
      flex: 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            if (controller.editImages.isEmpty) return const SizedBox();

            // Slider ke mutabiq slice display karega (initialIndex wala slice)
            final currentDicom = controller.editImages[controller.currentImageIndex.value - 1];

            return GestureDetector(
              onTapUp: (details) {
                if (controller.currentStudyId.value.isEmpty) {
                  // Agar AppSnackbar undefined ka error de toh aap yahan apna purana error handler laga sakte hain
                  AppSnackbar.error("Critical Error: Missing Study ID");
                  return;
                }
                controller.handleImageTap(details.localPosition, controller.currentStudyId.value, currentDicom.id.toString());
              },
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Image Layer
                    Positioned.fill(child: _dicomImageWidget(currentDicom.image, controller)),

                    // 2. Drawing Layer (Aapka Naya Hide/Show wala code)
                    Obx(() {
                      // Agar showAnnotations false hai, toh drawing mat dikhao
                      if (!controller.showAnnotations.value) {
                        return const SizedBox.shrink(); // Bilkul khali widget return kar dega
                      }

                      // Agar true hai, toh saari drawings dikhao
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: AnnotationPainter(controller.annotations.toList()),
                      );
                    }),

                    // 3. Slice Counter
                    _imageCounter("${controller.currentImageIndex.value} / ${controller.totalImages.value}"),

                    // 4. Visibility Toggle Button (Top Right par lagaya hai)
                    Positioned(
                      top: 0,
                      right: 70,
                      child: Obx(() {
                        bool isVisible = controller.showAnnotations.value;
                        return Container(
                          decoration: BoxDecoration(
                            color: isVisible ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isVisible ? Icons.visibility : Icons.visibility_off,
                              color: isVisible ? Colors.blue : Colors.grey,
                            ),
                            tooltip: isVisible ? "Hide Annotations" : "Show Annotations",
                            onPressed: () {
                              controller.toggleAnnotationsVisibility();
                            },
                          ),
                        );
                      }),
                    ),

                    Positioned(
                      top: 0,

                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.format_list_bulleted, color: Colors.blue),
                          tooltip: "View All Annotations",
                          onPressed: () async {
                            await controller.fetchStudyAnnotationsSummary();
                            _showAnnotationsSummarySheet(context, controller);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }



  Widget _buildRangeInfo(DicomEditController controller) {
    return Obx(() => controller.isRangeMode.value
        ? Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Range: Slice ${controller.startSliceIndex.value + 1} to ${controller.currentImageIndex.value}"),
          const Text("Draw to apply", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    )
        : const SizedBox());
  }

  Widget _dicomImageWidget(String path, DicomEditController controller) {
    if (path.isEmpty) return const Icon(Icons.broken_image, color: Colors.white);
    List<String> parts = path.split(RegExp(r'[\\/]+'));
    String url = "";
    if (parts.length >= 3) {
      url = "${controller.viewurl}/${parts[parts.length - 3]}/${parts[parts.length - 2]}/${parts.last}";
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
    );
  }

  Widget _imageCounter(String indexText) {
    return Positioned(
        top: 20,
        left: 20,
        child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Text(indexText, style: const TextStyle(color: Colors.white))
        )
    );
  }

  AppBar _appBar(DicomEditController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text("Edit Slice", style: TextStyle(color: Colors.blue)),
      actions: [
        Obx(() => IconButton(
          icon: Icon(
            controller.isAnnotationFilterOn.value ? Icons.filter_alt : Icons.filter_alt_off,
            color: controller.isAnnotationFilterOn.value ? Colors.orange : Colors.grey,
          ),
          onPressed: () => controller.toggleEditAnnotationFilter(),
          tooltip: "Show Annotated Slices Only",
        )),
        Obx(() => IconButton(
          icon: Icon(
            controller.isRangeMode.value ? Icons.layers : Icons.layers_clear,
            color: controller.isRangeMode.value ? Colors.blue : Colors.black,
          ),
          onPressed: controller.toggleRangeMode,
          tooltip: "Apply to Multiple Slices",
        )),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())
      ],
    );
  }



  void _showAnnotationsSummarySheet(BuildContext context, DicomEditController controller) {
    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Annotations Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                //  Naya loading state aur list use karein
                if (controller.isSummaryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                var summary = controller.studyAnnotationsSummary;

                if (summary.isEmpty) {
                  return const Center(child: Text("No annotations in this study."));
                }

                return ListView.builder(
                  itemCount: summary.length,
                  itemBuilder: (context, index) {
                    var data = summary[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text("${data['slice_index']}"), // Slice Number
                        ),
                        title: Text("Slice #${data['slice_index']}"),
                        subtitle: Text("${data['annotation_count']} Annotations found"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // JUMP TO SLICE LOGIC
                          controller.jumpToSlice(data['slice_index']);
                          Get.back(); // Sheet band kar do
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }



}

