import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/common/widgets/appbar/appbar.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';
import 'package:medra/modules/dicom_viewer/screen/widgets/dicom_image_card.dart';
import 'package:medra/modules/dicom_viewer/screen/widgets/dicom_thumbnail.dart';
import '../../dicom_edit/controller/dicom_edit_controller.dart';
import '../controller/dicom_viewer_controller.dart';

class DicomViewerScreen extends StatelessWidget {
  DicomViewerScreen({super.key});

  final DicomViewerController controller = Get.put(DicomViewerController());
  final DicomEditController editcontroller = Get.put(DicomEditController());
  final AuthController authcontroller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RAppBar(authcontroller: authcontroller),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.slot1Images.isEmpty && controller.slot2Images.isEmpty && !controller.isCompareMode.value)
          return const Center(child: Text("No Slices Found"));

        // if (controller.slot1Images.isEmpty && controller.slot2Images.isEmpty && !controller.isCompareMode.value)
        //   return const Center(child: Text("No Slices Found"));

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),

                    // SLOT 1
                    GestureDetector(
                      onLongPress: () {
                        if (controller.slot1Images.isNotEmpty) {
                            int idx = controller.firstSlotIndex.value;
                            if (idx >= controller.slot1Images.length) idx = 0;
                            controller.openAnnotationDetails(controller.slot1Images[idx]);
                        }
                      },
                      onTap: () => controller.selectSlot(1),
                      child: Obx(() {
                        //  List khali hai to container dikhao
                        if (controller.slot1Images.isEmpty) {
                          return _buildEmptySlot("Select a folder to load in Slot 1", controller.activeSlot.value == 1);
                        }

                        // Index out of bounds se bachne ke liye
                        int index = controller.firstSlotIndex.value;
                        if (index < 0 || index >= controller.slot1Images.length) index = 0;

                        return DicomImageCard(
                          dicom: controller.slot1Images[index],
                          selected: controller.activeSlot.value == 1,
                          sourceRef: controller.getOtherSlotReference(1),
                        );
                      }),
                    ),

                    const SizedBox(height: 5),

                    // SLOT 2
                    GestureDetector(
                      onLongPress: () {
                        if (controller.slot2Images.isNotEmpty) {
                          int idx = controller.secondSlotIndex.value;
                          if (idx >= controller.slot2Images.length) idx = 0;
                          controller.openAnnotationDetails(controller.slot2Images[idx]);
                        }
                      },
                      onTap: () => controller.selectSlot(2),
                      child: Obx(() {
                        // SAFETY CHECK: List khali hai to dabba dikhao
                        if (controller.slot2Images.isEmpty) {
                          return _buildEmptySlot("Select a folder to load in Slot 2", controller.activeSlot.value == 2);
                        }

                        //  SAFETY CHECK: Index out of bounds se bachne ke liye
                        int index = controller.secondSlotIndex.value;
                        if (index < 0 || index >= controller.slot2Images.length) index = 0;

                        return DicomImageCard(
                          dicom: controller.slot2Images[index],
                          selected: controller.activeSlot.value == 2,
                          sourceRef: controller.getOtherSlotReference(2),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            /// 2. SLIDER with SLOW & FAST buttons
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10),
            //   child: Row(
            //     children: [
            //       IconButton(
            //         onPressed: () {
            //           int currentIndex = controller.activeSlot.value == 1
            //               ? controller.firstSlotIndex.value
            //               : controller.secondSlotIndex.value;
            //           if (currentIndex > 0) {
            //             controller.changeMainImage(currentIndex - 1);
            //           }
            //         },
            //         icon: const Icon(Icons.fast_rewind, color: Colors.blue),
            //         tooltip: "Slow / Previous",
            //       ),
            //
            //       // SLIDER (Middle)
            //       Expanded(
            //         child: Obx(
            //           () => Slider(
            //             value:
            //                 (controller.activeSlot.value == 1
            //                         ? controller.firstSlotIndex.value
            //                         : controller.secondSlotIndex.value)
            //                     .toDouble(),
            //             min: 0,
            //             // Max value active slot ki list ke mutabiq set karein
            //             max:
            //                 (controller.activeSlot.value == 1
            //                         ? (controller.slot1Images.isEmpty
            //                               ? 0
            //                               : controller.slot1Images.length - 1)
            //                         : (controller.slot2Images.isEmpty
            //                               ? 0
            //                               : controller.slot2Images.length - 1))
            //                     .toDouble(),
            //
            //             onChanged: (value) =>
            //                 controller.changeMainImage(value.toInt()),
            //           ),
            //         ),
            //       ),
            //
            //       // FAST Button (Right)
            //       IconButton(
            //         onPressed: () {
            //           // Aik slice agay jao
            //           int currentIndex = controller.activeSlot.value == 1
            //               ? controller.firstSlotIndex.value
            //               : controller.secondSlotIndex.value;
            //           if (currentIndex < controller.seriesList.length - 1) {
            //             controller.changeMainImage(currentIndex + 1);
            //           }
            //         },
            //         icon: const Icon(Icons.fast_forward, color: Colors.blue),
            //         tooltip: "Fast / Next",
            //       ),
            //     ],
            //   ),
            // ),


            /// 2. SLIDER with SLOW & FAST buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // REWIND / BACK Button
                  GestureDetector(
                    onDoubleTap: () => controller.toggleAutoPlay(false), // Double tap par Auto-Back
                    child: IconButton(
                      onPressed: () {
                        controller.stopAutoPlay(); // Single click par auto-play ruk jaye
                        int currentIndex = controller.activeSlot.value == 1
                            ? controller.firstSlotIndex.value
                            : controller.secondSlotIndex.value;
                        if (currentIndex > 0) {
                          controller.changeMainImage(currentIndex - 1);
                        }
                      },
                      icon: Obx(() => Icon(
                          Icons.fast_rewind,
                          color: (controller.isPlaying.value) ? Colors.red : Colors.blue
                      )),
                    ),
                  ),

                  // SLIDER (Middle)
                  Expanded(

                    child: Obx(() => Slider(
                      value: (controller.activeSlot.value == 1
                          ? controller.firstSlotIndex.value
                          : controller.secondSlotIndex.value).toDouble(),
                      min: 0,
                      max: (controller.activeSlot.value == 1
                          ? (controller.slot1Images.isEmpty ? 0 : controller.slot1Images.length - 1)
                          : (controller.slot2Images.isEmpty ? 0 : controller.slot2Images.length - 1)).toDouble(),
                      onChanged: (value) {
                        controller.stopAutoPlay(); // Slider hilate hi auto-play band
                        controller.changeMainImage(value.toInt());
                      },
                    )),
                  ),

                  // FORWARD / FAST Button
                  GestureDetector(
                    onDoubleTap: () => controller.toggleAutoPlay(true), // Double tap par Auto-Forward
                    child: IconButton(
                      onPressed: () {
                        controller.stopAutoPlay(); // Single click par auto-play ruk jaye
                        int currentIndex = controller.activeSlot.value == 1
                            ? controller.firstSlotIndex.value
                            : controller.secondSlotIndex.value;
                        int maxIndex = controller.activeSlot.value == 1
                            ? controller.slot1Images.length - 1
                            : controller.slot2Images.length - 1;

                        if (currentIndex < maxIndex) {
                          controller.changeMainImage(currentIndex + 1);
                        }
                      },
                      icon: Obx(() => Icon(
                          Icons.fast_forward,
                          color: (controller.isPlaying.value) ? Colors.red : Colors.blue
                      )),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: SizedBox(
            //           height: 85,
            //           child: Obx(() => ListView.builder(
            //             scrollDirection: Axis.horizontal,
            //             itemCount: controller.images.length,
            //             itemBuilder: (context, index) {
            //               return DicomThumbnail(
            //                 image: controller.images[index].image,
            //                 selected: controller.firstSlotIndex.value == index ||
            //                     controller.secondSlotIndex.value == index,
            //                 onTap: () => controller.changeMainImage(index),
            //               );
            //             },
            //           )),
            //         ),
            //       ),
            //
            //       const SizedBox(width: 5),
            //       GestureDetector(
            //         onTap: () {
            //           controller.openMoreDetails();
            //         },
            //         child: Container(
            //           width: 45,
            //           height: 85,
            //           child: const Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Icon(Icons.more_horiz, color: Colors.blue),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. PEHLA CAROUSEL (Current Study) + 3 DOTS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: Obx(
                                  () => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.seriesList.length,
                                itemBuilder: (context, index) {
                                  var folder = controller.seriesList[index];

                                  String getFolderThumbnailUrl(String dbPath) {
                                    try {
                                      List<String> parts = dbPath.split(RegExp(r'[\\/]+'));
                                      if (parts.length >= 3) {
                                        String fileName = parts.last;
                                        String studyFolder = parts[parts.length - 2];
                                        String parentFolder = parts[parts.length - 3];
                                        return "${editcontroller.viewurl}$parentFolder/$studyFolder/$fileName";
                                      }
                                    } catch (e) {
                                      // ignore
                                    }
                                    return "";
                                  }

                                  return GestureDetector(
                                    // currentStudyId pass kiya hai
                                    onTap: () => controller.changeFolder(folder['folder_title'], controller.activeSlot.value, controller.currentStudyId!),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: (controller.activeSlot.value == 1
                                                    ? controller.firstSlotIndex.value.toString()
                                                    : controller.secondSlotIndex.value.toString()) == folder['folder_title']
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                getFolderThumbnailUrl(folder['image_path']),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.folder, size: 40, color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            folder['folder_title'],
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                          ),
                        ),
                      ),
                      // 3-DOT BUTTON
                      IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.blue, size: 30),
                          onPressed: () {
                            _showCompareStudiesSheet(context, controller);
                          }
                      )
                    ],
                  ),
                ),

                // 2. DOSRA CAROUSEL (Compared Study)
                Obx(() {
                  if (!controller.isCompareMode.value) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.study2Folders.length,
                                itemBuilder: (context, index) {
                                  var folder = controller.study2Folders[index];

                                  String getFolderThumbnailUrl(String dbPath) {
                                    try {
                                      List<String> parts = dbPath.split(RegExp(r'[\\/]+'));
                                      if (parts.length >= 3) {
                                        String fileName = parts.last;
                                        String studyFolder = parts[parts.length - 2];
                                        String parentFolder = parts[parts.length - 3];
                                        return "${editcontroller.viewurl}$parentFolder/$studyFolder/$fileName";
                                      }
                                    } catch (e) {
                                      return "";
                                    }
                                    return "";
                                  }

                                  return GestureDetector(
                                    // Hamesha Slot 2 aur secondStudyId use hogi
                                    onTap: () => controller.changeFolder(folder['folder_title'], 2, controller.secondStudyId!),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.grey.shade300, width: 2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                getFolderThumbnailUrl(folder['image_path']),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.folder, size: 40, color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            folder['folder_title'],
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: () {
                              //  List clear karne se pehle Slider ka control
                              // wapas Slot 1 ko de dein aur index 0 kar dein
                              controller.activeSlot.value = 1;
                              controller.secondSlotIndex.value = 0;

                              // Ab safely data clear karein
                              controller.isCompareMode.value = false;
                              controller.study2Folders.clear();
                              controller.slot2Images.clear();

                              // Doosri Study ki ID ko wapas Pehli jaisa kar dein
                              controller.secondStudyId = controller.currentStudyId;
                            }
                        )
                      ],
                    ),
                  );
                }),
              ],
            )
          ],
        );
      }),
    );
  }

  // Khali slot ke liye Placeholder Widget
  Widget _buildEmptySlot(String message, bool isSelected) {
    return Container(
      height: 285,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade800,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade600, size: 50),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }



  void _showCompareStudiesSheet(BuildContext context, DicomViewerController controller) {
    controller.fetchStudiesList();

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
                "Select Prior Study for Comparison",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.myStudiesList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: controller.myStudiesList.length,
                  itemBuilder: (context, index) {
                    var study = controller.myStudiesList[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder_shared, color: Colors.blue),
                        title: Text(study.title ?? "Study #${study.id}"),
                        subtitle: Text("ID: ${study.id}"),
                        trailing: const Icon(Icons.compare_arrows, color: Colors.grey),
                        onTap: () {
                          controller.loadSecondStudy(study.id.toString());
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
