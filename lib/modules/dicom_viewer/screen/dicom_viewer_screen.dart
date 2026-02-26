import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/common/widgets/appbar/appbar.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';
import 'package:medra/modules/dicom_viewer/screen/widgets/dicom_image_card.dart';
import 'package:medra/modules/dicom_viewer/screen/widgets/dicom_thumbnail.dart';
import '../controller/dicom_viewer_controller.dart';

class DicomViewerScreen extends StatelessWidget {
  DicomViewerScreen({super.key});

  final DicomViewerController controller =
  Get.put(DicomViewerController());

  final AuthController authcontroller =AuthController.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RAppBar(authcontroller: authcontroller),
      body:Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.images.isEmpty) return const Center(child: Text("No Slices Found"));

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
                      controller.openAnnotationDetails();
                    },
                    onTap: () => controller.selectSlot(1),
                    child: Obx(() => DicomImageCard(
                      dicom: controller.images[controller.firstSlotIndex.value],
                      selected: controller.activeSlot.value == 1,
                      // referencePos: controller.calculateReferenceLine(1),
                    )),
                  ),

                  const SizedBox(height: 5),

                  // SLOT 2
                  GestureDetector(
                    onLongPress: () {
                      controller.openAnnotationDetails();
                    },
                    onTap: () => controller.selectSlot(2),
                    child: Obx(() => DicomImageCard(
                      dicom: controller.images[controller.secondSlotIndex.value],
                      selected: controller.activeSlot.value == 2,
                      // referencePos: controller.calculateReferenceLine(2),
                    )),
                  ),
                ],
              ),
            ),
          ),


          /// 2. SLIDER with SLOW & FAST buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    int currentIndex = controller.activeSlot.value == 1
                        ? controller.firstSlotIndex.value
                        : controller.secondSlotIndex.value;
                    if (currentIndex > 0) {
                      controller.changeMainImage(currentIndex - 1);
                    }
                  },
                  icon: const Icon(Icons.fast_rewind, color: Colors.blue),
                  tooltip: "Slow / Previous",
                ),

                // SLIDER (Middle)
                Expanded(
                  child: Obx(() => Slider(
                    value: (controller.activeSlot.value == 1
                        ? controller.firstSlotIndex.value
                        : controller.secondSlotIndex.value).toDouble(),
                    min: 0,
                    max: (controller.images.length - 1).toDouble(),
                    divisions: controller.images.length > 1 ? controller.images.length - 1 : 1,
                    onChanged: (value) {
                      controller.changeMainImage(value.toInt());
                    },
                  )),
                ),

                // FAST Button (Right)
                IconButton(
                  onPressed: () {
                    // Aik slice agay jao
                    int currentIndex = controller.activeSlot.value == 1
                        ? controller.firstSlotIndex.value
                        : controller.secondSlotIndex.value;
                    if (currentIndex < controller.images.length - 1) {
                      controller.changeMainImage(currentIndex + 1);
                    }
                  },
                  icon: const Icon(Icons.fast_forward, color: Colors.blue),
                  tooltip: "Fast / Next",
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 85,
                    child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.images.length,
                      itemBuilder: (context, index) {
                        return DicomThumbnail(
                          image: controller.images[index].image,
                          selected: controller.firstSlotIndex.value == index ||
                              controller.secondSlotIndex.value == index,
                          onTap: () => controller.changeMainImage(index),
                        );
                      },
                    )),
                  ),
                ),

                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    controller.openMoreDetails();
                  },
                  child: Container(
                    width: 45,
                    height: 85,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.more_horiz, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }),
    );
  }
}