import 'dart:async';

import '../models/gallery_item_model.dart';
import 'gallery_repository.dart';

class MockGalleryRepository implements GalleryRepository {
  final StreamController<List<GalleryItemModel>> _controller =
      StreamController<List<GalleryItemModel>>.broadcast();

  final List<GalleryItemModel> _items = [
    GalleryItemModel(
      id: '1',
      name: 'Reference Name 1',
      imageUrl: 'https://images.unsplash.com/photo-1518895949257-7621c3c786d7?w=500&auto=format&fit=crop&q=80',
    ),
    GalleryItemModel(
      id: '2',
      name: 'Reference Name 2',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80',
    ),
    GalleryItemModel(
      id: '3',
      name: 'Reference Name 3',
      imageUrl: 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=500&auto=format&fit=crop&q=80',
    ),
    GalleryItemModel(
      id: '4',
      name: 'Reference Name 4',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop&q=80',
    ),
    GalleryItemModel(
      id: '5',
      name: 'Reference Name 5',
      imageUrl: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=500&auto=format&fit=crop&q=80',
    ),
  ];

  MockGalleryRepository() {
    // Schedule initial emit after listeners subscribe
    scheduleMicrotask(() {
      _controller.add(List.unmodifiable(_items));
    });
  }

  @override
  Stream<List<GalleryItemModel>> getImagesStream() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> addImage(GalleryItemModel item) async {
    // Insert at beginning for newest first
    _items.insert(0, item);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> deleteImage(String id) async {
    _items.removeWhere((element) => element.id == id);
    _controller.add(List.unmodifiable(_items));
  }

  void dispose() {
    _controller.close();
  }
}
