class StudyModel {
  final String id;
  final String title;
  final String bodyPart;
  final String modality;
  final String date;
  final String created_date;
  final bool aiAnalysed;
  final String patient_name;
  final String accessType;
  final String? permission_level;

  StudyModel({
    required this.id,
    required this.title,
    required this.bodyPart,
    required this.modality,
    required this.date,
    required this.created_date,
    required this.aiAnalysed,
    required this.patient_name,
    required this.accessType,
    required this.permission_level,
  });

  factory StudyModel.fromMap(Map<String, dynamic> map) {
    return StudyModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled',
      bodyPart: map['body_part']?.toString() ?? 'Unknown',
      modality: map['modality']?.toString() ?? 'N/A',
      date: map['study_date'] != null
          ? map['study_date'].toString().split(' ').first
          : 'No Date',
      created_date: map['created_at'] != null
          ? map['created_at'].toString().split('T').first
          : 'No Date',
      aiAnalysed: map['is_ai_processed'] ?? false,
      patient_name: map['patient_name']?.toString() ?? 'Unknown',
      accessType: map['access_type']?.toString() ?? 'OWNED',
      permission_level: map['permission_level']?.toString(),
    );
  }
}