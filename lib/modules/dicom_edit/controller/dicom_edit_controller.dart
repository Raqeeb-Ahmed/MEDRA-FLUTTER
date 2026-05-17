import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/services/api_service.dart';
import '../../../utills/snackbar/app_snackbar.dart';
import '../../dicom_viewer/controller/dicom_viewer_controller.dart';
import '../screen/color_picker_sheet.dart';


enum ToolType { circle, square, arrow, text, none }

class DicomEditController extends GetxController {
  static DicomEditController get instance => Get.find();

  var selectedTool = ToolType.none.obs;
  Rx<Color> selectedColor = Colors.red.obs;
  var showAnnotationInfo = false.obs;
  var currentStudyPermission = "full_access".obs;

  String viewurl ="http://192.168.100.170:8000/media/";

  // Coordinates aur Comments store karne ke liye
  var annotations = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  PageController pageController = PageController();


  final ApiService _apiService = ApiService();

  void selectTool(ToolType tool) {
    selectedTool.value = tool;
  }


  var currentImageIndex = 1.obs;
  var totalImages = 0.obs;
  var editImages = <dynamic>[].obs; // Poori images list ke liye
  var currentStudyId = "".obs;



  // Multiple slices range
  var isRangeMode = false.obs;
  var startSliceIndex = 0.obs;
  var endSliceIndex = 0.obs;



// Toggle variable
  var showAnnotations = true.obs;

  // Toggle Function
  void toggleAnnotationsVisibility() {
    showAnnotations.value = !showAnnotations.value;
  }


  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    if (args != null) {
      // 1. Study ID pakrein
      if (args['studyId'] != null) {
        currentStudyId.value = args['studyId'];
      }

      // 2. Folder ki poori images list set karein
      if (args['folderImages'] != null) {
        editImages.assignAll(args['folderImages']);
        totalImages.value = editImages.length;
      }

      // 3. Agar specific index (annotation jump) se aaye hain
      if (args['initialIndex'] != null) {
        // Index 0-based hota hai, UI display ke liye +1
        currentImageIndex.value = args['initialIndex'] + 1;
      }

      // 4. Pehli baar annotations fetch karein (Current Slice ke liye)
      if (editImages.isNotEmpty) {
        _loadCurrentSliceAnnotations();
      }
    }
  }

  void initializeFallback(dynamic singleDicom) {
    if (editImages.isEmpty) {
      editImages.add(singleDicom);
      totalImages.value = 1;
      currentImageIndex.value = 1;
      currentStudyId.value = singleDicom.study_id;

      // Purani annotations load karein
      fetchSavedAnnotations(singleDicom.study_id, singleDicom.id.toString());
    }
  }


  // Set kr dy ga Editscrren open hony sy pehly sara data
  void setupEditScreenData(List<dynamic> folderList, int sliceIndex, String studyId) async {
    editImages.assignAll(folderList);
    totalImages.value = folderList.length;
    currentImageIndex.value = sliceIndex + 1; // +1 ui k
    currentStudyId.value = studyId;

    pageController = PageController(initialPage: sliceIndex);
    currentStudyPermission.value = DicomViewerController.instance.currentStudyPermission.value;

    await fetchStudyAnnotationsSummary();
    // Data set hone ke baad annotations fetch karein
    if (editImages.isNotEmpty) {
      _loadCurrentSliceAnnotations();
    }
  }



  // Helper function taake code repeat na ho
  void _loadCurrentSliceAnnotations() {
    String sliceId = editImages[currentImageIndex.value - 1].id.toString();
    fetchSavedAnnotations(currentStudyId.value, sliceId);
  }

  // Slice change hone par annotations reload karne ke liye function
  void onSliceChanged(int index) {
    currentImageIndex.value = index + 1;
    _loadCurrentSliceAnnotations();
  }


  void openColorPicker() {
    Get.bottomSheet( ColorPickerSheet());
  }

  void addAnnotation() {
    showAnnotationInfo.value = true;
  }

  // void removeAnnotation() {
  //   showAnnotationInfo.value = false;
  // }


  /// Fetch Annotaions
  void fetchSavedAnnotations(String studyId, String sliceId) async {

    // if (currentStudyPermission.value == 'view_only') {
    //   // annotations.clear();
    //   print("Annotations hidden due to view_only permission");
    //   return;
    // }

    isLoading.value = true;
    annotations.clear();
    try {
      List<dynamic> savedData = await _apiService.getAnnotations(studyId, sliceId);
      for (var item in savedData) {
        var coords = item['coordinates_json'];

        Map<String, dynamic> finalMap = (coords is String)
            ? jsonDecode(coords)
            : Map<String, dynamic>.from(coords);
        finalMap['id'] = item['id'];
        finalMap['role'] = item['role'] ?? finalMap['role'] ?? 'unknown';

        annotations.add(finalMap);
      }
    } finally {
      isLoading.value = false;
    }
  }




  // Delete/remove Annotaion
  void removeAnnotation(String? annotationId, int index) async {
    // 1. Agar annotation abhi save nahi hui (sirf screen par hai)
    if (annotationId == null) {
      annotations.removeAt(index);
      return;
    }

    // 2. Database se delete karein
    bool success = await _apiService.deleteAnnotation(annotationId!);

    if (success) {
      annotations.removeAt(index);
      AppSnackbar.success("Annotation deleted");
    } else {
      AppSnackbar.info("Only Doctor Can delete");
    }
  }


  // void fetchSavedAnnotations(String studyId, String sliceId) async {
  //   isLoading.value = true;
  //   annotations.clear();
  //
  //   try {
  //     List<dynamic> savedData = await _apiService.getAnnotations(
  //         studyId, sliceId);
  //
  //     for (var item in savedData) {
  //       if (item is Map<String, dynamic>) {
  //         annotations.add(item); // Ab is mein id, role, tool_type sab hoga
  //       }
  //     }
  //     // for (var item in savedData) {
  //     //   // API se coordinates_json nikal kar local list mein daal dein
  //     //   var coords = item['coordinates_json'] as Map<String, dynamic>;
  //     //   annotations.add(coords);
  //     // }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }


  // void handleImageTap(Offset localPosition, String studyId, String sliceId) async {
  //   if (selectedTool.value == ToolType.none) return;
  //
  //   // 1. FORAN draw karein (Taake user ko sukoon miley)
  //   var tempAnnot = {
  //     "x": localPosition.dx,
  //     "y": localPosition.dy,
  //     "tool": selectedTool.value.name,
  //     "color": selectedColor.value.value.toString(),
  //   };
  //   annotations.add(tempAnnot);
  //
  //   // 2. Phir popup dikhayein comment ke liye
  //   TextEditingController commentController = TextEditingController();
  //   await Get.dialog(
  //     AlertDialog(
  //       title: const Text("Add Comment"),
  //       content: TextField(controller: commentController, autofocus: true),
  //       actions: [
  //         TextButton(onPressed: () {
  //           annotations.removeLast(); // Cancel par drawing mita dein
  //           Get.back();
  //         }, child: const Text("Cancel")),
  //         ElevatedButton(
  //           onPressed: () async {
  //             String comment = commentController.text;
  //             Get.back();
  //             try {
  //               // API Hit (Query Parameters)
  //               await _apiService.saveAnnotation(
  //                 studyId: studyId,
  //                 sliceId: sliceId,
  //                 coordinates: {...tempAnnot, "comment": comment},
  //               );
  //               annotations[annotations.length - 1] = {...tempAnnot, "comment": comment};
  //               AppSnackbar.success("Annotation Saved!");
  //             } catch (e) {
  //               annotations.removeLast(); // Fail par mita dein
  //               AppSnackbar.error("Database sync failed");
  //             }
  //           },
  //           child: const Text("Save"),
  //         )
  //       ],
  //     ),
  //   );
  // }





  void handleImageTap(Offset localPosition, String studyId, String sliceId) async {

    if (currentStudyPermission.value == 'view_only') {
      AppSnackbar.info("This study is in View Only mode. You cannot add annotations.");
      return;
    }

    if (selectedTool.value == ToolType.none) return;

    String userRole = GetStorage().read('role') ?? 'patient';

    // 1. FORAN draw karein (Taake user ko sukoon miley)
    var tempAnnot = {
      "x": localPosition.dx,
      "y": localPosition.dy,
      "tool": selectedTool.value.name,
      "color": selectedColor.value.value.toString(),
      "role": userRole,
    };
    annotations.add(tempAnnot);

    // 2. Phir popup dikhayein comment ke liye
    TextEditingController commentController = TextEditingController();
    await Get.dialog(
      AlertDialog(
        // Title ko dynamic kar diya taake user ko pata ho ke bulk save ho raha hai
        title: Text(isRangeMode.value ? "Apply to Multiple Slices" : "Add Comment"),
        content: TextField(controller: commentController, autofocus: true),
        actions: [
          TextButton(onPressed: () {
            annotations.removeLast(); // Cancel par drawing mita dein
            Get.back();
          }, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String comment = commentController.text;
              Get.back();

              var finalData = {...tempAnnot, "comment": comment};
              //  MAIN FIX: Yahan check karna hai ke kya Range Mode ON hai?
              if (isRangeMode.value) {
                // Agar ON hai, to naya Bulk Save function call hoga
                await saveAnnotationToRange(tempAnnot, comment);
              } else {
                // Agar OFF hai, to purana Single Save function call hoga
                try {
                  var response = await _apiService.saveAnnotation(
                    studyId: studyId,
                    sliceId: sliceId,
                    coordinates: finalData,
                  );
                  if (response != null && response['id'] != null) {
                    finalData['id'] = response['id']; // ID update kar di
                    finalData['role'] = response['role'] ?? userRole; // Role bhi update kar diya

                    // List mein purani temporary entry ko updated entry se badal dein
                    annotations[annotations.length - 1] = finalData;

                    AppSnackbar.success("Saved successfully");
                  }
                } catch (e) {
                  annotations.removeLast(); // Fail par mita dein
                  AppSnackbar.error("Database sync failed");
                }
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }






  void toggleRangeMode() {
    isRangeMode.value = !isRangeMode.value;
    if (isRangeMode.value) {
      // Range shuru karein current slice se
      startSliceIndex.value = currentImageIndex.value - 1;
      endSliceIndex.value = currentImageIndex.value - 1;
    }
  }


  Future<void> saveAnnotationToRange(Map<String, dynamic> tempAnnot, String comment) async {
    isLoading.value = true;
    try {
      int start = startSliceIndex.value;
      int end = currentImageIndex.value - 1; // Jahan tak user slider le kar gaya

      int realStart = start < end ? start : end;
      int realEnd = start < end ? end : start;

      //  API ke 'AnnotationCreate' schema ke mutabiq list tayyar karein
      List<Map<String, dynamic>> batchData = [];

      for (int i = realStart; i <= realEnd; i++) {
        batchData.add({
          "study_id": currentStudyId.value,
          "slice_id": editImages[i].id.toString(), // UUID as String
          "coordinates_json": {
            ...tempAnnot,
            "comment": comment,
          },
        });
      }

      //  API call
      bool success = await _apiService.saveAnnotationsBatch(batchData);

      if (success) {
        AppSnackbar.success("Successfully applied to ${batchData.length} slices!");
        isRangeMode.value = false; // Mode reset karein
        // Current slice ki annotations refresh karein taake user ko nazar aayein
        fetchSavedAnnotations(currentStudyId.value, editImages[currentImageIndex.value -1].id.toString());
      } else {
        AppSnackbar.error("Server failed to save batch");
      }
    } catch (e) {
      print("Bulk Save Error: $e");
      AppSnackbar.error("Something went wrong during bulk save");
    } finally {
      isLoading.value = false;
    }
  }








  var isSummaryLoading = false.obs;
  var studyAnnotationsSummary = <Map<String, dynamic>>[].obs;







  // 1. Ek getter jo sirf annotated slices ki list return karega
  Future<void> fetchStudyAnnotationsSummary() async {
    isSummaryLoading.value = true;
    studyAnnotationsSummary.clear();
    try {
      // 1. API se is study ki saari annotations le kar aao
      List<dynamic> allAnnotations = await _apiService.getAllStudyAnnotations(currentStudyId.value);

      // 2. Har slice ke hisab se count karein
      Map<String, int> counts = {};
      for (var ann in allAnnotations) {
        String sId = (ann['slice_id'] ?? ann['image_id'] ?? "").toString();
        if (sId.isNotEmpty) {
          counts[sId] = (counts[sId] ?? 0) + 1;
        }
      }

      // 3. UI ke liye List tayyar karein
      List<Map<String, dynamic>> summaryList = [];
      for (int i = 0; i < editImages.length; i++) {
        var slice = editImages[i];
        String currentSliceId = slice.id.toString();

        if (counts.containsKey(currentSliceId)) {
          summaryList.add({
            'slice_index': i + 1,
            'slice_id': currentSliceId,
            'annotation_count': counts[currentSliceId],
          });
        }
      }

      studyAnnotationsSummary.assignAll(summaryList);

    } catch (e) {
      print("Summary Load Error: $e");
    } finally {
      isSummaryLoading.value = false;
    }
  }

  // Direct Slice par Jump karne ka function
  void jumpToSlice(int index) {
    // 1. Reactive index badlein taake text aur slider foran shift hon
    currentImageIndex.value = index;

    // 2. 🔥 PHYSICAL JUMP: Dono formats handle karein
    if (pageController != null && pageController.hasClients) {
      pageController.jumpToPage(index - 1);
    } else {
      // Background single safe check toggle
      Future.microtask(() {
        if (pageController != null && pageController.hasClients) {
          pageController.jumpToPage(index - 1);
        }
      });
    }

    // 3. API se drawings load karein aur updates trigger karein
    _loadCurrentSliceAnnotations();
    onSliceChanged(index - 1);
  }




  // Variables section
  var isAnnotationFilterOn = false.obs;
  var originalEditImages = <dynamic>[].obs;

  void toggleEditAnnotationFilter() {
    if (!isAnnotationFilterOn.value) {
      // 1. Check karein ke summary mojud hai ya nahi
      if (studyAnnotationsSummary.isEmpty) {
        AppSnackbar.info("No annotations found in this study.");
        return;
      }

      // 2. Un Slice IDs ka Set banayein jin par annotations hain (Summary se)
      final Set<String> annotatedSliceIds = studyAnnotationsSummary
          .map((s) => s['slice_id'].toString())
          .toSet();

      // 3. Backup original list
      originalEditImages.assignAll(editImages);

      // 4. Filter karein
      var filtered = editImages.where((img) {
        return annotatedSliceIds.contains(img.id.toString());
      }).toList();

      if (filtered.isEmpty) {
        AppSnackbar.info("No annotated slices in this folder.");
        return;
      }

      // 5. Update State
      editImages.assignAll(filtered);
      isAnnotationFilterOn.value = true;
      totalImages.value = editImages.length;
      currentImageIndex.value = 1;

      _loadCurrentSliceAnnotations();
      AppSnackbar.success("Showing ${filtered.length} annotated slices");

    } else {
      // RESET Logic
      if (originalEditImages.isNotEmpty) {
        editImages.assignAll(originalEditImages);
        originalEditImages.clear();
      }

      isAnnotationFilterOn.value = false;
      totalImages.value = editImages.length;
      currentImageIndex.value = 1;

      _loadCurrentSliceAnnotations();
      AppSnackbar.info("Showing all slices");
    }
  }





  // List<dynamic> get allAnnotatedSlices {
  //   if (studyAnnotationsSummary.isEmpty) return [];
  //
  //   // Summary data ko UI ke liye return karein
  //   return studyAnnotationsSummary.toList();
  // }




  // Poori study ke liye alag list bnai hn ta k sari anotaion load ho sakain
  var allStudyAnnotations = <Map<String, dynamic>>[].obs;

  Future<void> fetchAllStudyAnnotations() async {
    if (currentStudyId.value.isEmpty) return;

    isLoading.value = true;
    try {
      List<dynamic> allData = await _apiService.getAllStudyAnnotations(currentStudyId.value);

      List<Map<String, dynamic>> formattedList = [];
      for (var item in allData) {
        var coords = item['coordinates_json'];
        Map<String, dynamic> finalMap = (coords is String)
            ? jsonDecode(coords)
            : Map<String, dynamic>.from(coords);

        finalMap['id'] = item['id'];
        finalMap['slice_id'] = item['slice_id'];
        finalMap['role'] = item['role'] ?? 'unknown';
        finalMap['tool_type'] = item['tool_type'] ?? finalMap['tool'];

        formattedList.add(finalMap);
      }

      allStudyAnnotations.assignAll(formattedList);
      allStudyAnnotations.refresh();
    } catch (e) {
      print("Global Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }




  var searchQuery  = " ".obs;
  // DicomEditController ke andar ye getter add karein
  List<dynamic> get filteredAllStudyAnnotations {
    if (allStudyAnnotations.isEmpty) return [];

    //  Agar search query khali hai to poori list dikhayein
    if (searchQuery.value.isEmpty) return allStudyAnnotations;

    String query = searchQuery.value.toLowerCase();

    return allStudyAnnotations.where((a) {
      if (a == null) return false;

      // 1. Data normalize karein (String check handle karte hue)
      var rawCoords = a['coordinates_json'];
      Map<String, dynamic> data = {};
      if (rawCoords is String) {
        data = jsonDecode(rawCoords);
      } else if (rawCoords is Map<String, dynamic>) {
        data = rawCoords;
      } else {
        data = a;
      }

      // 2. Searchable fields (Role 'Ai' small case mein bhi check hoga)
      final String comment = (data['comment'] ?? "").toString().toLowerCase();
      final String tool = (a['tool_type'] ?? data['tool'] ?? "").toString().toLowerCase();
      final String role = (a['role'] ?? data['role'] ?? "").toString().toLowerCase();

      return comment.contains(query) ||
          tool.contains(query) ||
          role.contains(query);
    }).toList();
  }






  //
  //
  // final Dio _dio = Dio(BaseOptions(
  //   baseUrl: "http://192.168.100.185:8000",
  //
  //   connectTimeout: Duration(seconds: 5),
  // ));
  //
  //
  // // DicomEditController.dart
  // var searchResults = <Map<String, dynamic>>[].obs;
  // var isSearching = false.obs;
  //
  // void searchAnnotations(String query) async {
  //   if (query.isEmpty) {
  //     isSearching.value = false;
  //     return;
  //   }
  //
  //   isSearching.value = true;
  //   try {
  //     final response = await _dio.get(
  //       "/annotations/search",
  //       queryParameters: {
  //         "query_str": query,
  //         "jwt_token": GetStorage().read('token'),
  //         "user_id": GetStorage().read('user_id'),
  //       },
  //     );
  //
  //     // Search results ko update karein
  //     searchResults.assignAll(List<Map<String, dynamic>>.from(response.data));
  //   } finally {
  //     isSearching.value = false;
  //   }
  // }
  //


}
