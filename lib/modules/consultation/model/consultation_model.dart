class ConsultationModel {
  final String id;
  final String patientName;
  final String study_id;
  final String scanType;
  final String date;
  final String status;
  final String image;

  ConsultationModel({
    required this.patientName,
    required this.study_id,
    required this.scanType,
    required this.date,
    required this.status,
    this.image = 'assets/logo/brain.jpg',
    required this.id,

  });

  Map<String, dynamic> toMap() {
    return {
      'doctorName': patientName,
      'study_id' : study_id,
      'scanType': scanType,
      'date': date,
      'status': status,
      // 'image': image,
    };
  }

  factory ConsultationModel.fromMap(Map<String, dynamic> map) {
    return ConsultationModel(
      id: (map['consultation_id'] ?? map['id'] ?? '').toString(),
      patientName: map['patient_name'] ?? map['doctor_name'] ?? 'Unknown',
      study_id: map['study_id']?.toString() ??
          map['studyId']?.toString() ??
          // Boht se cases mein join query mein ye 'id' ke naam se aati hai
          (map['id'] != null && map['id'].toString().length > 20 ? map['id'].toString() : ""),
      scanType: map['title'] ?? map['scan_type'] ?? 'N/A',
      date: (map['study_date'] ?? map['date'] ?? '').toString(),
      status:map['consultation_status'] ?? map['status'] ?? 'pending',
      image: 'assets/logo/brain.jpg',

    );
  }

}
