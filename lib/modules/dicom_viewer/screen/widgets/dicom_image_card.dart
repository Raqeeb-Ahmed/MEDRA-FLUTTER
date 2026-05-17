import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:medra/modules/dicom_edit/screen/dicom_edit_screen.dart';
import '../../../dicom_edit/controller/dicom_edit_controller.dart';
import '../../controller/dicom_viewer_controller.dart';
import '../../controller/reference_line_painter_controller.dart';
import '../../model/dicom_image_model.dart';

class DicomImageCard extends StatelessWidget {
  final DicomImageModel dicom;
  final bool selected;
  // final double referencePos;
  final Map<String, dynamic>? sourceRef;

   DicomImageCard({
    super.key,
    required this.dicom,
    required this.selected,  this.sourceRef,
  });

  final DicomViewerController controller = DicomViewerController.instance;
  final DicomEditController editcontroller = DicomEditController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              // Database ke path se StudyID aur Filename nikal kar "media" URL banana
              // Image.network ka URL:
              (() {
                try {
                  // Path: media/uploads\d509...\image.jpg
                  List<String> parts = dicom.image.split(RegExp(r'[\\/]+'));

                  if (parts.length >= 3) {
                    String fileName = parts.last;
                    String studyFolder = parts[parts.length - 2];
                    String parentFolder = parts[parts.length - 3]; // Yeh 'uploads' hoga

                    return "${editcontroller.viewurl}$parentFolder/$studyFolder/$fileName";
                  }
                } catch (e) {

                  print("URL logic error: $e");
                }
                return "";
              })(),

              width: double.infinity,
              height: 285,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(height: 285, child: Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                print("FAILED PATH: ${dicom.image}");
                return const SizedBox(
                  height: 285,
                  child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                );
              },
            ),
          ),
          // if (referencePos >= 0)
          //   IgnorePointer(
          //     child: CustomPaint(
          //       size: const Size(double.infinity, 285),
          //       painter: ReferenceLinePainter(slicePosition: referencePos),
          //     ),
          //   ),

          if (sourceRef != null && dicom.reference != null)
            IgnorePointer(
              child: CustomPaint(
                size: const Size(double.infinity, 285),
                painter: ReferenceLinePainter(
                  sourceRef: sourceRef,
                  targetRef: dicom.reference,
                ),
              ),
            ),

          // if (referencePos >= 0)
          //   IgnorePointer(
          //     child: CustomPaint(
          //       size: const Size(double.infinity, 285),
          //       painter: ReferenceLinePainter(slicePosition: referencePos),
          //     ),
          //   ),

          // DicomImageCard widget mein Positioned button add karein
          // Positioned(
          //   bottom: 10,
          //   right: 10,
          //   child: CircleAvatar(
          //     backgroundColor: Colors.red.withOpacity(0.8),
          //     child: IconButton(
          //       icon: const Icon(Icons.bug_report, color: Colors.white), // Tumor marker icon
          //       onPressed: () => controller.markAsTumor(),
          //     ),
          //   ),
          // ),

          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dicom.index,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
                onTap: () {
                  controller.navigateToEditScreenFromViewer(dicom);
                },

                child: const Icon(Icons.edit, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
