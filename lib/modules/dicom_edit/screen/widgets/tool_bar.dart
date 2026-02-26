import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dicom_viewer_controller.dart';

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
    final controller = Get.find<DicomEditController>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tool("Circle", Icons.circle_outlined,
                  () => onToolSelected(ToolType.circle),
              controller.selectedTool.value == ToolType.circle),
          _tool("Square", Icons.crop_square,
                  () => onToolSelected(ToolType.square),
              controller.selectedTool.value == ToolType.square),
          _tool("Mark", Icons.arrow_right_alt,
                  () => onToolSelected(ToolType.arrow),
              controller.selectedTool.value == ToolType.arrow),
          _tool("Text", Icons.text_fields,
                  () => onToolSelected(ToolType.text),
              controller.selectedTool.value == ToolType.text),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: onColorTap,
          ),
        ],
      ),
    );
  }

  Widget _tool(
      String label,
      IconData icon,
      VoidCallback onTap,
      bool selected,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: selected ? Colors.blue : Colors.black),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
