import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dicom_edit_controller.dart';

class ToolBar extends StatelessWidget {
  final Function(ToolType) onToolSelected;
  final VoidCallback onColorTap;

  const ToolBar({
    super.key,
    required this.onToolSelected,
    required this.onColorTap,
  });

  @override
  Widget build(BuildContext context) {
    // Controller ko find karein taake hum selectedTool ko listen kar sakein
    final controller = Get.find<DicomEditController>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Har tool ke liye build function call karein
          _tool("Circle", Icons.circle_outlined, ToolType.circle, controller),
          _tool("Square", Icons.crop_square, ToolType.square, controller),
          // _tool("Mark", Icons.arrow_right_alt, ToolType.arrow, controller),
          _tool("Text", Icons.text_fields, ToolType.text, controller),

          // Color Lens Icon
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.black),
            onPressed: onColorTap,
          ),
        ],
      ),
    );
  }

  // Updated _tool helper function
  Widget _tool(String label, IconData icon, ToolType type, DicomEditController controller) {
    return GestureDetector(
      onTap: () => onToolSelected(type),
      child: Obx(() {
        // Yeh Obx sirf is icon ka rang tab badlega jab selectedTool change hoga
        bool isSelected = controller.selectedTool.value == type;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        );
      }),
    );
  }
}