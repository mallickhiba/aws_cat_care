import 'models/models.dart';

abstract class CatRepository {
  Future<Cat> createCat(Cat cat);

  Future<List<Cat>> getCat();

  Future<Cat> getCatByID(String catId);

  updateCat(Cat cat) {}

  deleteCat(String catId) {}
}
