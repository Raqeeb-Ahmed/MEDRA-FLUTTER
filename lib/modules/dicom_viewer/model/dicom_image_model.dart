class DicomImageModel {
  final String image;
  final String index;
  final Map<String, dynamic>? reference;

  DicomImageModel({required this.image, required this.index, this.reference});

  factory DicomImageModel.fromJson(Map<String, dynamic> map) {
    return DicomImageModel(
      image: map['image'],
      index: map['index'],
      reference: map['reference'],
    );
  }
}