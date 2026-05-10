import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/data/models/qore_model.dart';
import 'package:study/data/db/db_service.dart';

class DBRepository {
  final dbService = DBService.instance;

  Future<void> saveUser({required UserModel user}) async {
    await dbService.insertUser(user);
  }

  Future<UserModel?> getUser() async {
    return await dbService.getUser();
  }

  Future<void> updateUser({required UserModel user}) async {
    await dbService.updateUser(user);
  }

  Future<void> deleteAll() async {
    await dbService.deleteAll();
  }

  Future<void> deleteUser() async {
    await dbService.deleteUser();
  }

  // QORE
  Future<void> saveQore({
    required QoreDbModel qore,
    required List<TextModel> texts,
    required List<AudioModel> audios,
    required List<ImageModel> images,
  }) async {
    await dbService.insertQore(qore, texts, audios, images);
  }

  // search
  Future<List<QoreModel>> getQoresBySearchQuery(String query) async {
    return await dbService.getQoresBySearchQuery(query);
  }

  Future<void> saveText({required TextModel text}) async {
    await dbService.insertText(text);
  }

  Future<void> deleteText({required TextModel text}) async {
    await dbService.deleteText(text);
  }

  Future<List<ImageModel>> getImages(String qoreId) async {
    return await dbService.getImages(qoreId);
  }

  Future<void> saveImage({required ImageModel image}) async {
    await dbService.insertImage(image);
  }

  Future<void> deleteImage({required String id}) async {
    await dbService.deleteImage(id);
  }

  Future<void> saveAudio({required AudioModel audio}) async {
    await dbService.insertAudio(audio);
  }

  Future<List<QoreModel>> getAllQore() async {
    return await dbService.getAllQore();
  }

  Future<QoreModel> getQoreById(String id) async {
    return await dbService.getQoreById(id);
  }

  Future<void> updateQore(QoreModel qore) async {
    await dbService.updateQore(qore);
  }

  Future<void> deleteQore(String id) async {
    await dbService.deleteQore(id);
  }
}

// PROVIDERS

final dbRepositoryProvider = Provider((ref) => DBRepository());

final userProvider = FutureProvider<UserModel?>((ref) {
  return ref.watch(dbRepositoryProvider).getUser();
});

// QORE PROVIDERS

final qoreListProvider = FutureProvider<List<QoreModel>>((ref) {
  return ref.watch(dbRepositoryProvider).getAllQore();
});

final qoreByIdProvider = FutureProvider.family<QoreModel, String>((ref, id) {
  return ref.watch(dbRepositoryProvider).getQoreById(id);
});

final qoreImagesProvider = FutureProvider.family<List<ImageModel>, String>((
  ref,
  qoreId,
) {
  return ref.watch(dbRepositoryProvider).getImages(qoreId);
});

final qoreSearchProvider = FutureProvider.family<List<QoreModel>, String>((
  ref,
  query,
) {
  return ref.watch(dbRepositoryProvider).getQoresBySearchQuery(query);
});

// refresh

void refreshAll(WidgetRef ref) {
  ref.invalidate(qoreListProvider);
  ref.invalidate(qoreByIdProvider);
  ref.invalidate(qoreImagesProvider);
  ref.invalidate(qoreSearchProvider);
}

void refreshUser(WidgetRef ref) {
  ref.invalidate(userProvider);
}
