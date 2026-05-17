import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/dicom_edit/controller/dicom_edit_controller.dart';
import 'package:medra/utills/snackbar/app_snackbar.dart';
import '../../../data/services/api_service.dart';
import '../../dicom_edit/screen/dicom_edit_screen.dart';
import '../../studies/model/study_model.dart';
import '../model/dicom_image_model.dart';
import '../screen/widgets/annotation_details_sheet.dart';
import '../screen/widgets/more_details_sheet.dart';


class DicomViewerController extends GetxController {
  static DicomViewerController get instance => Get.find();

  // var selectedIndex = 0.obs;

  DicomEditController editcontroller = Get.put(DicomEditController());


  var isLoading = false.obs;
  var images = <DicomImageModel>[].obs;
  final ApiService _apiService = ApiService();

  var currentStudyPermission = "full_access".obs;

  // Arguments handle karne ke liye variables
  // var title = "".obs;
  // var patient = "".obs;


  // Niche slider ke liye (Folders) wali list


  var seriesList = <dynamic>[].obs;


  // Upar ki 2 bari images ke index
  // Slot 1 aur Slot 2 ki apni apni images list
  var slot1Images = <DicomImageModel>[].obs;
  var slot2Images = <DicomImageModel>[].obs;

  // Ye track rakhne ke liye ke agli click kis slot ko update karegi
  var firstSlotIndex = 0.obs;
  var secondSlotIndex = 0.obs;
  var activeSlot = 1.obs;


  // for annotation
  var annotations;
  String? currentStudyId;
  String? secondStudyId;

  void selectSlot(int slotNumber) {
    activeSlot.value = slotNumber;
  }


  var showAnnotations = true.obs;

  void toggleAnnotations(bool value) {
    showAnnotations.value = value;
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


  var selectedDicomForDetails = Rxn<DicomImageModel>();


  void openAnnotationDetails(DicomImageModel dicom) {
    selectedDicomForDetails.value = dicom;
    Get.bottomSheet(
      const AnnotationDetailsSheet(),
      isScrollControlled: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }


  @override
  void onInit() {
    annotations = editcontroller.annotations;
    super.onInit();
    var args = Get.arguments;
    if (args != null) {
      currentStudyId = args['studyId'];
      secondStudyId = currentStudyId;
      currentStudyPermission.value = args['permission_level'] ?? "full_access";
      fetchAllStudyAnnotations(currentStudyId!);
      fetchSeries(currentStudyId!);
    }
  }



  // function jo saari annotations aik sath laye ga
  void fetchAllStudyAnnotations(String studyId) async {
    if (currentStudyPermission.value == 'view_only') return; //

    isLoading.value = true;
    try {
      var allData = await _apiService.getAllStudyAnnotations(studyId);
      annotations.assignAll(allData); // Ab saari annotations load ho jayengi
      annotations.refresh();
    } catch (e) {
      print("Global Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchSeries(String studyId) async {
    isLoading.value = true;
    try {
      await editcontroller.fetchStudyAnnotationsSummary();
      var data = await _apiService.getSeries(studyId);
      seriesList.assignAll(data);

      if (seriesList.isNotEmpty) {
        String firstFolder = seriesList[0]['folder_title'];


        // Dono slots ke liye bari bari folder load karein
        await changeFolder(firstFolder, 1, studyId);
        await changeFolder(firstFolder, 2, studyId);
      }
    } catch (e) {
      AppSnackbar.error("Series failed to load");
    } finally {
      isLoading.value = false;
    }
  }

  // Future return karein taake await kiya ja sakay
  Future<void> changeFolder(String folderTitle, int slot,
      String targetStudyId) async {
    try {
      var data = await _apiService.getSlicesByFolder(
          targetStudyId, folderTitle);
      // for (var slice in data) {
      //   slice.hasAnnotation = editcontroller.annotations.any(
      //           (a) => a['slice_id'].toString() == slice.id.toString()
      //   );
      // }
      if (slot == 1) {
        slot1Images.assignAll(data);
        firstSlotIndex.value = 0;
      } else {
        slot2Images.assignAll(data);
        secondSlotIndex.value = 0;
      }
    } catch (e) {
      print("Folder Load Error: $e");
      AppSnackbar.error("Failed to load folder $folderTitle");
    }
  }

  void changeMainImage(int index) {
    if (activeSlot.value == 1) {
      firstSlotIndex.value = index.clamp(0, slot1Images.length - 1);
    } else {
      secondSlotIndex.value = index.clamp(0, slot2Images.length - 1);
    }
    update();
  }

  // URl Construct LOgic
  String constructFullUrl(String imagePath) {
    try {
      // Path format: media/uploads\d509...\image.jpg
      // Split logic to handle both forward and backslashes
      List<String> parts = imagePath.split(RegExp(r'[\\/]+'));

      if (parts.length >= 3) {
        String fileName = parts.last;
        String studyFolder = parts[parts.length - 2];
        String parentFolder = parts[parts.length - 3]; // Usually 'uploads'

        /// editcontroller.viewurl use karein (e.g., http://192.168.x.x:8000/media/)
        return "${editcontroller.viewurl}$parentFolder/$studyFolder/$fileName";
      }
    } catch (e) {
      print("URL construction error: $e");
    }
    return "";
  }


  //###########################

// Calculate cross referrencing ine
//   double calculateReferenceLine(int targetSlot) {
//     int sourceIdx = (targetSlot == 2) ? firstSlotIndex.value : secondSlotIndex
//         .value;
//     var sourceStack = (targetSlot == 2) ? slot1Images : slot2Images;
//     var targetStack = (targetSlot == 2) ? slot2Images : slot1Images;
//
//     if (sourceStack.isEmpty || targetStack.isEmpty) return -1.0;
//
//     try {
//       // DB ke 'reference' column se data uthayien
//       var sourceRef = sourceStack[sourceIdx].reference;
//       var targetRef = targetStack.first.reference;
//
//       if (sourceRef == null || targetRef == null) return -1.0;
//
//       // ImagePositionPatient ka 3rd element (Z-axis)
//       double sourceZ = sourceRef['ImagePositionPatient'][2];
//       double firstZ = targetStack.first.reference?['ImagePositionPatient'][2];
//       double lastZ = targetStack.last.reference?['ImagePositionPatient'][2];
//
//       double totalRange = (lastZ - firstZ).abs();
//       if (totalRange == 0) return -1.0;
//
//       // Normalized position (0.0 to 1.0)
//       double relativePos = (sourceZ - firstZ).abs() / totalRange;
//       return relativePos.clamp(0.0, 1.0);
//     } catch (e) {
//       return -1.0;
//     }
//   }


  //  Ye doosre slot ki image ka DICOM metadata return karega
  Map<String, dynamic>? getOtherSlotReference(int currentSlot) {
    try {
      if (currentStudyId != secondStudyId && slot2Images.isNotEmpty) {
        return null;
      }

      if (currentSlot == 1) {
        if (slot2Images.isEmpty) return null;
        return slot2Images[secondSlotIndex.value].reference;
      } else {
        if (slot1Images.isEmpty) return null;
        return slot1Images[firstSlotIndex.value].reference;
      }
    } catch (e) {
      return null;
    }
  }

  // double calculateReferenceLine(int targetSlot) {
  //   var sourceDicom = (targetSlot == 1) ? slot2Images[secondSlotIndex.value] : slot1Images[firstSlotIndex.value];
  //   var targetDicom = (targetSlot == 1) ? slot1Images[firstSlotIndex.value] : slot2Images[secondSlotIndex.value];
  //
  //   var sourceRef = sourceDicom.reference;
  //   var targetRef = targetDicom.reference;
  //   var targetStack = (targetSlot == 1) ? slot1Images : slot2Images;
  //
  //   if (sourceRef == null || targetRef == null) return -1.0;
  //
  //   // Check Plane Types
  //   bool isTargetAxial = isAxialView(targetDicom);
  //   bool isSourceAxial = isAxialView(sourceDicom);
  //
  //   try {
  //     // Case 1: Source is Sagittal, Target is Axial -> Line should be Vertical (X-axis)
  //     if (!isSourceAxial && isTargetAxial) {
  //       double sourceX = sourceRef['ImagePositionPatient'][0]; // X-coordinate
  //       double firstX = targetStack.first.reference?['ImagePositionPatient'][0];
  //       double lastX = targetStack.last.reference?['ImagePositionPatient'][0];
  //       return (sourceX - firstX).abs() / (lastX - firstX).abs();
  //     }
  //
  //     // Case 2: Source is Axial, Target is Sagittal -> Line should be Horizontal (Z-axis)
  //     else {
  //       double sourceZ = sourceRef['ImagePositionPatient'][2]; // Z-coordinate
  //       double firstZ = targetStack.first.reference?['ImagePositionPatient'][2];
  //       double lastZ = targetStack.last.reference?['ImagePositionPatient'][2];
  //       return (sourceZ - firstZ).abs() / (lastZ - firstZ).abs();
  //     }
  //   } catch (e) {
  //     return -1.0;
  //   }
  // }


  // dicom_viewer_controller.dart mein ye function add karein
  bool isAxialView(DicomImageModel dicom) {
    try {
      // Orientation Patient ka data uthayein
      // Axial orientation aksar [1, 0, 0, 0, 1, 0] ke qareeb hoti hai
      var orientation = dicom.reference?['ImageOrientationPatient'];
      if (orientation == null) return true; // Default axial maan lein

      double z1 = orientation[2].abs(); // ImageOrientationPatient ka 3rd value
      double z2 = orientation[5].abs(); // ImageOrientationPatient ka 6th value

      // Agar Z components zero ke qareeb hain, to ye Axial hai
      return (z1 < 0.5 && z2 < 0.5);
    } catch (e) {
      return true;
    }
  }


  // Annotaions query
  var searchQuery = "".obs;

// Filtered annotations nikalne ka tareeqa
  List<dynamic> get filteredAnnotations {
    if (annotations.isEmpty) return [];

    var current = annotations.toList();

    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();

      current = current.where((a) {
        if (a == null) return false;

        // 1. Coordinates data nikalne ka sahi tareeqa (String handle karte hue)
        var rawCoords = a['coordinates_json'];
        Map<String, dynamic> data = {};

        if (rawCoords is String) {
          data = jsonDecode(rawCoords);
        } else if (rawCoords is Map<String, dynamic>) {
          data = rawCoords;
        } else {
          data = a; // Agar flat structure ho
        }

        // 2. Searchable fields (Role ko bhi shamil kiya)
        final String comment = (data['comment'] ?? "").toString().toLowerCase();
        final String tool = (a['tool_type'] ?? data['tool'] ?? "").toString().toLowerCase();
        final String role = (a['role'] ?? data['role'] ?? "").toString().toLowerCase();

        return comment.contains(query) ||
            tool.contains(query) ||
            role.contains(query);
      }).toList();
    }

    return current;
  }



// Viewer se Edit screen par poore folder ke sath jane ke liye
  void navigateToEditScreenFromViewer(DicomImageModel dicom) {
    try {
      List<DicomImageModel> targetList = [];
      int targetIndex = slot1Images.indexWhere((img) => img.id == dicom.id);

      if (targetIndex != -1) {
        targetList = slot1Images;
      } else {
        targetIndex = slot2Images.indexWhere((img) => img.id == dicom.id);
        if (targetIndex != -1) {
          targetList = slot2Images;
        }
      }

      if (targetIndex != -1 && targetList.isNotEmpty) {
        // Edit Screen open hone se pehle Controller ko poora folder aur index de dein
        DicomEditController.instance.setupEditScreenData(
          targetList,
          targetIndex,
          currentStudyId ?? "",
        );

        Get.to(() => DicomEditScreen());
      } else {
        AppSnackbar.error("Slice not found in current view");
      }
    } catch (e) {
      print("Navigation Error: $e");
    }
  }

  void jumpToEditScreen(dynamic annotation) {
    try {
      String sliceId = annotation['slice_id'].toString();
      var targetList = (activeSlot.value == 1) ? slot1Images : slot2Images;
      int targetIndex = targetList.indexWhere((img) =>
      img.id.toString() == sliceId);

      if (targetIndex != -1) {
        Get.back();

        // Data setup kr raha hn edit screen ko bhejny k liya
        DicomEditController.instance.setupEditScreenData(
          targetList,
          targetIndex,
          currentStudyId ?? "",
        );

        Get.to(() => DicomEditScreen());
      } else {
        AppSnackbar.error("Slice not found");
      }
    } catch (e) {
      print("Navigation Error: $e");
    }
  }


  ///////////////////// Multiple OCmparisson View
//  COMPARISON Views
  var isCompareMode = false.obs;
  var myStudiesList = <StudyModel>[].obs; // Bottom sheet ki list
  var study2Folders = <dynamic>[]
      .obs; // Dosri study ke thumbnails/folders ka data

  // 1. Bottom Sheet ke liye saari studies mangwana
  Future<void> fetchStudiesList() async {
    String userId = GetStorage().read('user_id');
    try {
      var studies = await _apiService.fetchMyStudies(userId);
      myStudiesList.assignAll(studies);
    } catch (e) {
      AppSnackbar.error("Failed to load studies list");
    }
  }

  // 2. Sheet mein se Study select hone par uska data mangwana
  Future<void> loadSecondStudy(String studyId) async {
    Get.back(); // Pehle Bottom Sheet band karein
    try {
      secondStudyId = studyId;
      // Yahan api.getSeries ya getSlices call karein (jo aap currently carousel ke liye use karte hain)
      var folders = await _apiService.getSeries(studyId);
      study2Folders.assignAll(folders);
      isCompareMode.value = true; // Dosra carousel screen par show ho jayega
    } catch (e) {
      AppSnackbar.error("Could not load second study");
    }
  }


    // var isAnnotationFilterOn = false.obs;
    // var originalSlot1Images = <DicomImageModel>[].obs; // Backup ke liye
    //
    // // Toggle Function
    // void toggleAnnotationFilter() async {
    //   if (!isAnnotationFilterOn.value) {
    //     isLoading.value = true;
    //     try {
    //       var allAnnotations = await _apiService.getStudyAnnotations(currentStudyId!);
    //
    //       if (allAnnotations.isEmpty) {
    //         AppSnackbar.info("No annotations found.");
    //         isLoading.value = false;
    //         return;
    //       }
    //
    //       final Set<String> annotatedSliceIds = allAnnotations
    //           .map((a) => a['slice_id'].toString().toLowerCase().trim())
    //           .toSet();
    //
    //       // 1. Backup saari images
    //       originalSlot1Images.assignAll(slot1Images);
    //
    //       // 2. Filtered list banayein
    //       var filtered = slot1Images.where((slice) {
    //         return annotatedSliceIds.contains(slice.id.toString().toLowerCase().trim());
    //       }).toList();
    //
    //       if (filtered.isEmpty) {
    //         AppSnackbar.info("No annotated slices in this folder.");
    //         isLoading.value = false;
    //         return;
    //       }
    //
    //       // 3. 🔥 CRITICAL STEP: List ko clear kar ke nayi bharein aur index reset karein
    //       slot1Images.assignAll(filtered);
    //       isAnnotationFilterOn.value = true;
    //
    //       // Index ko pehli slice par le jayein taake UI refresh ho
    //       firstSlotIndex.value = 0;
    //
    //       // 4. Force Update
    //       slot1Images.refresh();
    //       update();
    //
    //       AppSnackbar.success("Showing ${filtered.length} annotated slices");
    //     } catch (e) {
    //       print("Filter Error: $e");
    //     } finally {
    //       isLoading.value = false;
    //     }
    //   } else {
    //     // RESET LOGIC
    //     if (originalSlot1Images.isNotEmpty) {
    //       slot1Images.assignAll(originalSlot1Images);
    //     }
    //     isAnnotationFilterOn.value = false;
    //     firstSlotIndex.value = 0;
    //
    //     slot1Images.refresh();
    //     update();
    //     AppSnackbar.info("All slices restored");
    //   }
    // }








  Timer? playTimer;
  var isPlaying = false.obs;

  void toggleAutoPlay(bool forward) {
    if (isPlaying.value) {
      stopAutoPlay();
    } else {
      startAutoPlay(forward);
    }
  }

  void startAutoPlay(bool forward) {
    isPlaying.value = true;
    playTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      int currentIndex = activeSlot.value == 1 ? firstSlotIndex.value : secondSlotIndex.value;
      int maxIndex = activeSlot.value == 1 ? slot1Images.length - 1 : slot2Images.length - 1;

      if (forward) {
        if (currentIndex < maxIndex) {
          changeMainImage(currentIndex + 1);
        } else {
          stopAutoPlay(); // Aakhri slice par ruk jaye
        }
      } else {
        if (currentIndex > 0) {
          changeMainImage(currentIndex - 1);
        } else {
          stopAutoPlay(); // Pehli slice par ruk jaye
        }
      }
    });
  }

  void stopAutoPlay() {
    playTimer?.cancel();
    isPlaying.value = false;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    stopAutoPlay();
  }
}