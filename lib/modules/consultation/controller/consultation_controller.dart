import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/utills/snackbar/app_snackbar.dart';

import '../../../data/services/api_service.dart';
import '../model/consultation_model.dart';

class ConsultationController extends GetxController {
  static ConsultationController get instance => Get.find();

  final ApiService _api = ApiService();
 final localstorage = GetStorage();
  var consultations = <ConsultationModel>[].obs;
  var doctors = [].obs;
  var studies = [].obs;


  // Selected values for dropdowns
  var selectedDoctorId = "".obs;
  var selectedStudyId = "".obs;
  var isLoading = false.obs;



  var selectedConsultationId = "".obs;
  var selectedReferDoctorId = "".obs;


  var selectedPermission = "view_only".obs;

    @override
    void onInit() {
      super.onInit();
      localstorage.read('user_id');
      localstorage.read('token');
      loadInitialData();
      refreshConsultations();
    }

  @override
  void onClose() {
      consultations.clear();
      doctors.clear();
      studies.clear();
      super.onClose();
  }


  String user_id = GetStorage().read('user_id');

  void loadInitialData() async {
    isLoading.value = true;
    try {

      final results = await Future.wait([
        _api.fetchDoctors(),
        _api.fetchMyStudies(user_id),
      ]);

      doctors.assignAll(results[0]);
      print(doctors);
      studies.assignAll(results[1]);
      print(doctors);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitConsultation() async {
    if (selectedDoctorId.isEmpty || selectedStudyId.isEmpty) {
      Get.snackbar("Error", "Select Both Doctor And Study",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    bool success = await _api.createConsultation(
      patientId: user_id,
      doctorId: selectedDoctorId.value,
      studyId: selectedStudyId.value,
    );

    if (success) {
      Get.back();
      loadInitialData();
      AppSnackbar.success("Consultation Request Sent Successfully");
    }
  }


  void refreshConsultations() async {
    isLoading.value = true;
    try {
      String role = localstorage.read('role') ?? 'patient';
      String token = localstorage.read('token');
      String userId = localstorage.read('user_id');

      if (role == 'doctor') {
        var data = await _api.fetchDoctorConsultations(token: token, doctorId: userId);

        consultations.value = data.map((item) { return ConsultationModel.fromMap(item);}).toList();
      } else {
        var data = await _api.fetchConsultations(userId);
        consultations.assignAll(data);
      }
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  // update Consultation Status
  Future<void> changeStatus(String consultationId, String status) async {
    String token = localstorage.read('token');
    String userId = localstorage.read('user_id');

    bool success = await _api.updateConsultationStatus(
      token: token,
      userId: userId,
      consultationId: consultationId,
      newStatus: status,
    );

    if (success) {
      AppSnackbar.success("Status updated to $status");
       refreshConsultations();
    } else {
      AppSnackbar.error("Failed to update status");
    }
  }




  // Refer Consultation to another doctor
  Future<void> submitReferral() async {
    if (selectedConsultationId.isEmpty || selectedReferDoctorId.isEmpty) {
      AppSnackbar.error("Select both Patient and Doctor");
      return;
    }

    String token = localstorage.read('token');
    String senderId = localstorage.read('user_id');

    bool success = await _api.referConsultationtodoctor(
      token: token,
      userId: senderId,
      consultationId: selectedConsultationId.value,
      referred_doctor_id: selectedReferDoctorId.value,
    );

    if (success) {
      Get.back();
      refreshConsultations();
      AppSnackbar.success("Consultation Referred Successfully");
    }
  }




  // Share Study to any user
  Future<void> submitShareStudy(String studyId) async {
    if (selectedReferDoctorId.value.isEmpty) {
      AppSnackbar.error("Please select a user to share with");
      return;
    }

    bool success = await _api.share_study(
      study_id: studyId,
      shared_to_id: selectedReferDoctorId.value,
      permission_level: selectedPermission.value,
    );

    if (success) {
      Get.back();
      AppSnackbar.success("Study shared successfully!");
    } else {
      AppSnackbar.error("Failed to share study. Make sure you are the owner.");
    }
  }


}

