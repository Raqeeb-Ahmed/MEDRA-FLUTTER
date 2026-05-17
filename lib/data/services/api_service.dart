import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

import '../../modules/authentication/model/user_model.dart';
import '../../modules/consultation/model/consultation_model.dart';
import '../../modules/dicom_viewer/model/dicom_image_model.dart';
import '../../modules/studies/model/study_model.dart';
import '../../modules/studies/model/study_upload_response_model.dart';


class ApiService {

  final local = GetStorage();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://192.168.100.170:8000",
    connectTimeout: Duration(seconds: 5),
  ));


  void onInit() {
    local.read('user_id');
    local.read('token');
    local.read('role');
  }

  /// 1. USER SIGNUP
  Future<Response> signupUser(UserModel user) async {
    try {
      final response = await _dio.post("/users/signup", data: user.toMap());
      return response;

    } on DioException catch (e) {
      // print("DATA: ${e.response?.data}");
      throw e.response?.data['detail'] ?? "Signup failed";
    }
  }

  /// 2. USER LOGIN
  Future<Response> loginUser(String username, String password) async {
    try {
      final response = await _dio.post(
        "/users/login",
        data: {
          "username": username,
          "password": password,
        },
      );
      return response;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? "Login failed";
    }
  }

  /// 3. UPLOAD DICOM STUDY (.ZIP)
  Future<StudyUploadResponse> uploadStudyZip(String filePath, String userId) async {
    String token = local.read('token') ?? "";

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: "study.zip"),
    });

    try {
      // Hit Api
      final response = await _dio.post(
        "/studies/upload_folder",
        data: formData,
        // onSendProgress: (sent, total) {
        //   double progress = sent / total;
        //   print("Upload ${(progress * 100).toStringAsFixed(2)}%");
        // },
        queryParameters: {
          "jwt_Token": token,
          "user_id": userId,
        },
      );
      return StudyUploadResponse.fromMap(response.data);
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? "File upload failed";
    }
  }

  /// 4. Fetch User Studies
  Future<List<StudyModel>> fetchMyStudies(String userId) async {
    try {
      String localjwttoken =local.read('token');
      final response = await _dio.get(
        "/patient/studies",
        queryParameters: {"user_id": userId,"jwt_Token":localjwttoken},
      );

      if (response.data['status'] == 'success') {
        List data = response.data['data'];
        return data.map((item) => StudyModel.fromMap(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? "Studies Not Loaded ";
    }
  }

  // // 5. Fetch All Studies Slices
  // Future<List<DicomImageModel>> getSlices(String studyId) async {
  //   try {
  //     final response = await _dio.get("/studies/$studyId/slices");
  //
  //     if (response.data['status'] == 'success') {
  //       List data = response.data['data'];
  //       return data.map((item) => DicomImageModel.fromJson(item)).toList();
  //     }
  //     return [];
  //   } on DioException catch (e) {
  //     throw e.response?.data['detail'] ?? "Slices Not Loaded";
  //   }
  // }



  /// 5. Series (Folders) fetch karne ke liye
  Future<List<dynamic>> getSeries(String studyId) async {
    try {
      final response = await _dio.get("/studies/series_details",
        queryParameters: {
        "study_id": studyId,
          "jwt_token": GetStorage().read('token'),
        "user_id": GetStorage().read('user_id'),},
        // data: {
        //   "jwt_token": local.read('token'),
        //   "user_id": local.read('user_id'),
        // },
      );
      return response.data;
    } catch (e) {
      throw "Series failed to load";
    }
  }

  /// 5. Kisi specific folder ki images fetch karne ke liye
  Future<List<DicomImageModel>> getSlicesByFolder(String studyId, String folderTitle) async {
    try {
      final response = await _dio.get(
        "/studies/series/images",
        queryParameters: {
          "study_id": studyId,
          "folder_title": folderTitle,
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      List data = response.data;
      return data.map((item) => DicomImageModel.fromJson(item)).toList();
    } catch (e) {
      throw "Folder slices failed to load";
    }
  }



  /// 6. Fetch All Doctors
  Future<List<dynamic>> fetchDoctors() async {
    try {
      final response = await _dio.get("/users/doctors", 
        queryParameters: {
        "user_id": local.read('user_id'),
          "jwt_Token":local.read('token')},
      );
      if (response.data['status'] == 'success') {
        return response.data['data'];
      }
      print(response);
      return [];
    } catch (e) {
      throw "Doctors Not Found";
    }
  }


  // Get All users
  Future<List<dynamic>> fetchAllUsers() async {
    try {
      final response = await _dio.get("/users/all",
        queryParameters: {
          "user_id": local.read('user_id'),
          "jwt_Token": local.read('token')
        },
      );
      if (response.data['status'] == 'success') {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  /// 7. create consultation
  Future<bool> createConsultation({
    required String patientId,
    required String doctorId,
    required String studyId,
  }) async {
    try {
      String localjwttoken =local.read('token');
      final response = await _dio.post(
        "/patient/consultations",
        data: {
          "user": {
            "jwt_token": localjwttoken,
            "user_id": patientId,
          },
          "consult": {
            "patient_id": patientId,
            "doctor_id": doctorId,
            "study_id": studyId,
          }
        },
      );
      return response.data['status'] == 'success';
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }


  /// 8. Fetch/Retrieve consultation
  Future<List<ConsultationModel>> fetchConsultations(String user_id) async {
    try {
      String localjwttoken = local.read('token');
      final response = await _dio.post("/patient/consultations/all/study",
          data: {"user_id":user_id, "jwt_token":localjwttoken});
      if (response.data['status'] == 'success') {
        List data = response.data['data'];
        return data.map((item) => ConsultationModel.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      throw "Consultations failed to laod";

    }

  }

  /// 9 FEtch Doctor Consultation record
  Future<List<dynamic>> fetchDoctorConsultations({required String token, required String doctorId}) async {
    try {
      final response = await _dio.post(
        "/doctor/consultations/all",
        data: {
          "jwt_token": token,
          "user_id": doctorId,
        },
      );
      return response.data;
    } catch (e) {
      throw "Doctor consultations Failed to load";
    }
  }



  /// 10. Profile Update
  Future<bool> updateProfile({
    required String token,
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      final response = await _dio.put(
        "/users/update-profile",
        queryParameters: {
          "jwt_Token": token,
          "user_id": userId,
        },
        data: {
          "username": username,
          "email": email,
        },
      );
      return response.data['status'] == 'success';
    } catch (e) {
      print("Profile Update Error: $e");
      return false;
    }
  }

  /// 11. Password Change
  Future<bool> changePassword({
    required String token,
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        "/users/change-password",
        queryParameters: {
          "jwt_Token": token,
          "user_id": userId,
        },
        data: {
          "old_password": oldPassword,
          "new_password": newPassword,
        },
      );
      return response.data['status'] == 'success';
    } catch (e) {
      print("Password Change Error: $e");
      return false;
    }
  }



  /// 12 Update Consultation Status
  Future<bool> updateConsultationStatus({
    required String token,
    required String userId,
    required String consultationId,
    required String newStatus,
  }) async {
    try {
      final response = await _dio.patch(
        "/doctor/consultations/status_update",
        data: {
          "data": {
            "new_status": newStatus,
            "consultation_id": consultationId,
          },
          "doctor": {
            "jwt_token": token,
            "user_id": userId,
          },
        },

      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("API Error: ${e.response?.data}");
      return false;
    }
  }



  /// 13 Refer Dicom Study to another Doctor
  Future<bool> referConsultationtodoctor({
    required String token,
    required String userId,
    required String consultationId,
    required String referred_doctor_id,
  }) async {
    try {
      final response = await _dio.patch(
        "/doctor/consultation/refer",
        data: {
          "data": {
            "consultation_id": consultationId,
            "referred_doctor_id": referred_doctor_id,
          },
          "sending_doctor": {
            "jwt_token": token,
            "user_id": userId,
          },
        },

      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("API Error: ${e.response?.data}");
      return false;
    }
  }




  /// 14. Share Study to other Patient/Doctor
  Future<bool> share_study({
    required String study_id,
    required String shared_to_id,
    required String permission_level,
  }) async {
    try {
      final response = await _dio.post(
        "/studies/share",
        data: {
          "share_data": {
            "study_id": study_id,
            "shared_to_id": shared_to_id,
            "permission_level": permission_level,
          },
          "user": {
            "jwt_token": GetStorage().read('token'),
            "user_id": GetStorage().read('user_id'),
          },
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }



  // ApiService.dart
  Future<Map<String, dynamic>?> saveAnnotation({
    required String studyId,
    required String sliceId,
    required Map<String, dynamic> coordinates,
  }) async {
    try {
      // (AnnotationCreate data)
      final Map<String, dynamic> requestData = {
        "study_id": studyId,
        "slice_id": sliceId,
        "coordinates_json": coordinates, // Direct Map bhej raha hon
      };


    final response = await _dio.post(
        "/annotations",
        data: requestData,
        queryParameters: {
          // Auth parameters query mein hi rahengi (User_Auth model ke mutabiq)
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Backend Error: ${e.response?.data}");
      throw "Save Failed";
    }
  }



  // Get Annotation by slice
  Future<List<dynamic>> getAnnotations(String studyId, String sliceId) async {
    try {
      final response = await _dio.get(
        "/annotations/retrieve",
        queryParameters: {
          "study_id": studyId,
          "slice_id": sliceId,
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      return response.data; // List of annotations
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }



  Future<bool> deleteAnnotation(String annotationId) async {
    try {
      //delete("/{annotation_id}")
      await _dio.delete(
        "/annotations/$annotationId",
        queryParameters: {
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      return true; // Success
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }





  Future<bool> saveAnnotationsBatch(List<Map<String, dynamic>> dataList) async {
    try {
      final response = await _dio.post(
        "/annotations/batch",
        data: dataList, // Flutter list ko Dio khud JSON array bana deta hai
        queryParameters: {
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Batch Save Error: $e");
      return false;
    }
  }








  // GEt ALL Annotaions
  Future<List<dynamic>> getAllStudyAnnotations(String studyId) async {
    try {
      final response = await _dio.get(
        "/annotations/retrieve_study",
        queryParameters: {
          "study_id": studyId,
          "jwt_token": GetStorage().read('token'),
          "user_id": GetStorage().read('user_id'),
        },
      );
      return response.data; // Poori study ki saari annotations
    } catch (e) {
      print("Fetch All Annotations Error: $e");
      return [];
    }
  }




  // Future<List<dynamic>> getStudyAnnotations(String studyId) async {
  //   try {
  //     final response = await _dio.get("/studies/$studyId/annotations/all");
  //     return response.data;
  //   } catch (e) {
  //     print("Error fetching all study annotations: $e");
  //     return [];
  //   }
  // }


}






//
// 1. Logic: Kaunsi Line Kab Dikhani Hai?
// Radiant aur doosre viewers mein ye asool (rule) hota hai:
//
// Axial View: Is par hamesha Vertical line dikhayi jati hai (jo Sagittal/Coronal ki position batati hai).
//
// Sagittal/Coronal View: In par hamesha Horizontal line dikhayi jati hai (jo Axial slice ki height batati hai).