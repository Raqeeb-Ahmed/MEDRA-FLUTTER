class DicomImageModel {
  final String id;
  final String study_id;
  final String image;
  final String index;
  bool hasAnnotation;
  final Map<String, dynamic>? reference;

  DicomImageModel({required this.image, required this.index, this.reference, required this.id, required this.study_id,this.hasAnnotation = false,});

  factory DicomImageModel.fromJson(Map<String, dynamic> map) {
    return DicomImageModel(
      id: map['id'] ?? "",
      image: map['image_path'] ?? "",
      index: map['instance_number'].toString(), // 'index' ki jagah instance_number
      reference: map['reference'],
      study_id: map['study_id']?.toString() ?? map['studyId']?.toString() ?? "",
    );
  }
}