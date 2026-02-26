class StudyUploadResponse {
  final String message;
  final int studiesCreated;
  final int slicesImported;
  final List<String> studyIds;
  final String? bodyPart;
  final String? studyDate;
  final String? modality;
  final String? patient_name;

  StudyUploadResponse({
    required this.message,
    required this.studiesCreated,
    required this.slicesImported,
    required this.studyIds,
    required this.bodyPart,
    required this.studyDate,
    required this.modality,
    required this.patient_name,

  });

  factory StudyUploadResponse.fromMap(Map<String, dynamic> map) {
    return StudyUploadResponse(
      message: map['message'],
      studiesCreated: map['studies_created'],
      slicesImported: map['slices_imported'],
      studyIds: List<String>.from(map['study_ids']),
      bodyPart: map['body_part'],
      studyDate: map['study_date'],
      modality: map['modality'],
      patient_name: map['patient_name'],
    );
  }
}