//handle all methods
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseCatRepository implements CatRepository {
  final catCollection = FirebaseFirestore.instance.collection('cats');

  @override
  Future<Cat> createCat(Cat cat) async {
    try {
      cat.catId = const Uuid().v1();

      await catCollection.doc(cat.catId).set(cat.toEntity().toDocument());

      return cat;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Cat>> getCat() {
    try {
      return catCollection.get().then((value) => value.docs
          .map((e) => Cat.fromEntity(CatEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateCat(Cat cat) async {
    final catDoc = FirebaseFirestore.instance.collection('cats').doc(cat.catId);
    await catDoc.update(cat.toEntity().toDocument());
  }
}
