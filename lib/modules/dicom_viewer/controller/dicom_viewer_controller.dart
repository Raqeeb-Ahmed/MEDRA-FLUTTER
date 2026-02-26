import 'package:get/get.dart';
import 'package:medra/utills/snackbar/app_snackbar.dart';
import '../../../data/services/api_service.dart';
import '../model/dicom_image_model.dart';
import '../screen/widgets/annotation_details_sheet.dart';
import '../screen/widgets/more_details_sheet.dart';


class DicomViewerController extends GetxController {
  static DicomViewerController get instance => Get.find();
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var images = <DicomImageModel>[].obs;
  final ApiService _apiService = ApiService();

  // Arguments handle karne ke liye variables
  var title = "".obs;
  var patient = "".obs;



  // Upar ki 2 bari images ke index
  var firstSlotIndex = 0.obs;
  var secondSlotIndex = 1.obs;

  // Ye track rakhne ke liye ke agli click kis slot ko update karegi
  var activeSlot = 1.obs;

  void selectSlot(int slotNumber) {
    activeSlot.value = slotNumber;
  }


  // Niche thumbnail click hone par sirf active slot change hoga
  void changeMainImage(int index) {
    if (activeSlot.value == 1) {
      firstSlotIndex.value = index;
    } else {
      secondSlotIndex.value = index;
    }
  }



  var aiEnabled = false.obs;
  var annotationEnabled = true.obs;

  void toggleAI(bool value) {
    aiEnabled.value = value;
  }

  void toggleAnnotation(bool value) {
    annotationEnabled.value = value;
  }

  void openMoreDetails() {
    Get.bottomSheet(
      const MoreDetailsSheet(),
      isScrollControlled: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }

  void openAnnotationDetails() {
    Get.bottomSheet(
      const AnnotationDetailsSheet(),
      isScrollControlled: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }



  // double calculateReferenceLine(int targetSlot) {
  //   // Agar hum Slot 1 ki line Slot 2 par dekhna chahte hain
  //   int sourceIndex = (targetSlot == 2) ? firstSlotIndex.value : secondSlotIndex.value;
  //   int targetIndex = (targetSlot == 2) ? secondSlotIndex.value : firstSlotIndex.value;
  //
  //   if (images.isEmpty || sourceIndex >= images.length || targetIndex >= images.length) return -1.0;
  //
  //   var sourceRef = images[sourceIndex].reference;
  //   var targetRef = images[targetIndex].reference;
  //
  //   if (sourceRef == null || targetRef == null) return -1.0;
  //
  //   try {
  //     // DICOM Math: ImagePositionPatient [x, y, z]
  //     // Z-axis aksar slice ki depth batata hai
  //     List sourcePos = sourceRef['ImagePositionPatient'];
  //     List targetPos = targetRef['ImagePositionPatient'];
  //     double sliceThickness = targetRef['SliceThickness'] ?? 5.0;
  //
  //     // Target image ki total depth (Z range) nikalna
  //     // Ye aik simplified version hai real-time cross-referencing ka
  //     double diff = (sourcePos[2] - targetPos[2]).abs();
  //     double normalizedPos = diff / (images.length * sliceThickness);
  //
  //     return normalizedPos.clamp(0.0, 1.0);
  //   } catch (e) {
  //     return -1.0;
  //   }
  // }

  @override
  void onInit() {
    super.onInit();
    // Screen par aatay hi arguments read karein
    var args = Get.arguments;
    if (args != null) {
      title.value = args['title'] ?? "Study";
      patient.value = args['patient'] ?? "Unknown";
      fetchSlices(args['studyId']);
    }
  }

  @override
  void onClose() {
    images.clear();
    super.onClose();
  }

  void fetchSlices(String studyId) async {
    isLoading.value = true;
    try {
      var data = await _apiService.getSlices(studyId);
      images.assignAll(data);
    } catch (e) {
      AppSnackbar.error("Slices failed to load");
    } finally {
      isLoading.value = false;
    }
  }

  void changeImage(int index) => selectedIndex.value = index;

}