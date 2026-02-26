import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';

import '../../controller/consultation_controller.dart';
import '../../model/consultation_model.dart';

class ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;

   ConsultationCard({super.key, required this.consultation});

  Color getStatusColor() {
    switch (consultation.status.toLowerCase()) {
      case 'pending':
        return Colors.grey.shade200;
      case 'confirmed':
        return Colors.blueGrey.shade100;
      case 'finished':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.grey.shade400;
      default:
        return Colors.grey.shade200;
    }
  }

  List<String> statusOptions = ['pending', 'confirmed', 'finished', 'cancelled'];

  final ConsultationController controller = Get.put(ConsultationController());
  @override
  Widget build(BuildContext context) {
    String role = GetStorage().read('role') ?? 'patient';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              consultation.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consultation.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  consultation.scanType,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  consultation.date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          role == 'doctor'
              ? Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: getStatusColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusOptions.contains(consultation.status.toLowerCase())
                    ? consultation.status.toLowerCase()
                    : 'pending',
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                style: const TextStyle(fontSize: 11, color: Colors.black),
                items: statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalizeFirst ?? value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != consultation.status.toLowerCase()) {
                    controller.changeStatus(consultation.id, newValue);
                  }
                },
              ),
            ),
          )
              :Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    consultation.status,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
        ],
      ),
    );
  }
}
