class ConsultationModel {
  final String id;
  final String doctorName;
  final String scanType;
  final String date;
  final String status;
  final String image;

  ConsultationModel({
    required this.doctorName,
    required this.scanType,
    required this.date,
    required this.status,
    this.image = 'assets/logo/logo.png',
    required this.id,

  });

  Map<String, dynamic> toMap() {
    return {
      'doctorName': doctorName,
      'scanType': scanType,
      'date': date,
      'status': status,
      // 'image': image,
    };
  }

  factory ConsultationModel.fromMap(Map<String, dynamic> map) {
    return ConsultationModel(
      id: (map['consultation_id'] ?? map['id'] ?? '').toString(),
      doctorName: map['patient_name'] ?? map['doctor_name'] ?? 'Unknown',
      scanType: map['title'] ?? map['scan_type'] ?? 'N/A',
      date: (map['study_date'] ?? map['date'] ?? '').toString(),
      status:map['consultation_status'] ?? map['status'] ?? 'pending',
      image: 'assets/logo/logo.png',

    );
  }

}
