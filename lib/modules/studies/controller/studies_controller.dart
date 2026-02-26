import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/data/services/api_service.dart';
import 'package:medra/utills/snackbar/app_snackbar.dart';
import '../model/study_model.dart';

class StudiesController extends GetxController {
  static StudiesController get instance => Get.find();


  var isLoading = false.obs;
  final ApiService _studyService = ApiService();
  final local = GetStorage();
  var uploadedFileName = "".obs;


  // Bottom sheet step
  var step = 0.obs;


  var studies = <StudyModel>[].obs;

  // Metadata (Step-2)
  var patientName = ''.obs;
  var bodyPart = ''.obs;
  var studyDate = ''.obs;

  void nextStep() => step.value = 1;

  void reset() {
    step.value = 0;
    patientName.value = '';
    bodyPart.value = '';
    studyDate.value = '';
    uploadedFileName.value= '';
  }


  final patientNameController = TextEditingController();
  final bodyPartController = TextEditingController();
  final studyDateController = TextEditingController();


  // Future<void> pickAndUploadStudy() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['zip'],
  //   );
  //
  //   if (result != null) {
  //     String filePath = result.files.single.path!;
  //     uploadedFileName.value = result.files.single.name;
  //
  //     // get user_id from local storage
  //     String userId = local.read('user_id') ?? "";
  //
  //     isLoading.value = true;
  //     try {
  //       var response = await _studyService.uploadStudyZip(filePath, userId);
  //       Get.snackbar("Success", "Process Complete: ${response.slicesImported} slices found.");
  //     } catch (e) {
  //       uploadedFileName.value = "";
  //       Get.snackbar("Upload Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
  //     } finally {
  //       isLoading.value = false;
  //     }
  //   }
  // }


  Future<void> pickAndUploadStudy() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      isLoading.value = true;
      String filePath = result.files.single.path!;
      uploadedFileName.value = result.files.single.name;

      try {
        var response = await _studyService.uploadStudyZip(
            filePath, local.read('user_id'));

        bodyPartController.text = response.modality ?? "Unknown";
        studyDateController.text = response.studyDate ?? "";
        patientNameController.text = response.patient_name ?? "Unknown Patient";

        Get.snackbar("Success", "Upload Complete");
        await getAllStudies();
        nextStep();
      } catch (e) {
        Get.snackbar("Error", e.toString());
      } finally {
        isLoading.value = false;
      }
    }
  }




  @override
  void onInit() {
    super.onInit();
    getAllStudies();
  }

  // All Users Studies
  Future<void> getAllStudies() async {
    isLoading.value = true;
    // studies.clear();
    try {
      String userId = local.read('user_id') ?? "";

      // print(userId);
      if (userId.isNotEmpty) {
        var results = await _studyService.fetchMyStudies(userId);
        print(results);
        studies.assignAll(results);
      }
    } catch (e) {
      print(studies);
      AppSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }





  @override
  void onClose() {
    studies.clear();
    super.onClose();
  }


}
