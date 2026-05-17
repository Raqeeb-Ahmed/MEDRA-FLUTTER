import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class AnnotationCard extends StatelessWidget {
  final Map<String, dynamic>? annotation; // Real data from DB
  final VoidCallback onDelete;

  const AnnotationCard({
    super.key,
    required this.annotation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Coordinates_json se data nikalna
    // final coords = annotation?['coordinates_json'] as Map<String, dynamic>;
    final dynamic rawCoords = annotation?['coordinates_json'];
   // Agar DB se aaya hai to coordinates_json uthaye, warna poora annotation hi coordinates hai
    final Map<String, dynamic> coords = rawCoords is Map<String, dynamic>
        ? rawCoords
        : (annotation ?? {});
    final String tool = annotation?['tool_type'] ?? "Shape"; //
    final String comment = coords['comment'] ?? "No description";
    final String role = (annotation?['role'] ?? coords['role'] ?? "User").toString();

    // Color string ko wapas Color object mein badalna
    final Color cardColor = Color(int.parse(coords['color'] ?? "4280330240"));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real Tool Type (Circle/Rectangle)
                Text(tool.capitalizeFirst!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // Real Comment/Description
                Text(comment),
                // Real Role (Doctor/Patient)
                Text("Role: ${role.capitalizeFirst!}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                // Timestamp (Optional)
                Text(annotation?['created_at'] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          )
        ],
      ),
    );
  }
}