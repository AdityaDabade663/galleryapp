import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gallery_item_model.dart';
import 'gallery_repository.dart';

class FirestoreGalleryRepository implements GalleryRepository {
  final FirebaseFirestore _firestore;
  final String collectionPath;

  FirestoreGalleryRepository({
    FirebaseFirestore? firestore,
    this.collectionPath = 'gallery_images',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<GalleryItemModel>> getImagesStream() {
    return _firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GalleryItemModel.fromJson(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  @override
  Future<void> addImage(GalleryItemModel item) async {
    final docRef = _firestore.collection(collectionPath).doc();
    final data = item.toJson()..['id'] = docRef.id;
    await docRef.set(data);
  }

  @override
  Future<void> deleteImage(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}

