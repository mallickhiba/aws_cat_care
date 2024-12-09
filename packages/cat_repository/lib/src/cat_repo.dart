import 'models/models.dart';

abstract class CatRepository {
  Future<Cat> createCat(Cat cat);

  Future<List<Cat>> getCat();

  updateCat(Cat cat) {}
}
