import '../models/gallery_item_model.dart';

abstract class GalleryRepository {
  Stream<List<GalleryItemModel>> getImagesStream();
  Future<void> addImage(GalleryItemModel item);
  Future<void> deleteImage(String id);
}
