import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? localPath;
  final DateTime createdAt;

  GalleryItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.localPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLocal => localPath != null && localPath!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localPath': localPath,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GalleryItemModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parsedDate;
    final createdVal = json['createdAt'];

    if (createdVal is Timestamp) {
      parsedDate = createdVal.toDate();
    } else if (createdVal is String) {
      parsedDate = DateTime.tryParse(createdVal) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return GalleryItemModel(
      id: docId ?? (json['id'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      localPath: json['localPath'] as String?,
      createdAt: parsedDate,
    );
  }

  GalleryItemModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? localPath,
    DateTime? createdAt,
  }) {
    return GalleryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
