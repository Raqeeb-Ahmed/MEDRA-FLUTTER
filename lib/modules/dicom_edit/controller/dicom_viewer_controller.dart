import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/color_picker_sheet.dart';


enum ToolType { circle, square, arrow, text }

class DicomEditController extends GetxController {
  var currentImageIndex = 1.obs;
  var totalImages = 20;

  var selectedTool = ToolType.circle.obs;
  Rx<Color> selectedColor = Colors.green.obs;

  var showAnnotationInfo = false.obs;

  void selectTool(ToolType tool) {
    selectedTool.value = tool;
  }

  void openColorPicker() {
    Get.bottomSheet( ColorPickerSheet());
  }

  void addAnnotation() {
    showAnnotationInfo.value = true;
  }

  void removeAnnotation() {
    showAnnotationInfo.value = false;
  }
}
