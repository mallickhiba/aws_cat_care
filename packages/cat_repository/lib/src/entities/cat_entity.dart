import 'package:user_repository/user_repository.dart';

class CatEntity {
  String catId;
  String catName;
  String location;
  int age;
  String sex;
  String color;
  String description;
  String image;
  bool isFixed;
  bool isAdopted;
  MyUser myUser;

  CatEntity({
    required this.catId,
    required this.catName,
    required this.location,
    required this.age,
    required this.sex,
    required this.color,
    required this.description,
    required this.image,
    required this.isFixed,
    required this.isAdopted,
    required this.myUser,
  });

  Map<String, Object?> toDocument() {
    return {
      'catId': catId,
      'catName': catName,
      'location': location,
      'age': age,
      'sex': sex,
      'color': color,
      'description': description,
      'image': image,
      'isFixed': isFixed,
      'isAdopted': isAdopted,
      'myUser': myUser.toEntity().toDocument(),
    };
  }

  static CatEntity fromDocument(Map<String, dynamic> doc) {
    return CatEntity(
        catId: doc['catId'] as String,
        catName: doc['catName'] as String,
        location: doc['location'] as String,
        age: doc['age'] as int,
        sex: doc['sex'] as String,
        color: doc['color'] as String,
        description: doc['description'] as String,
        image: doc['image'] as String,
        isFixed: doc['isFixed'] as bool,
        isAdopted: doc['isAdopted'] as bool,
        myUser: MyUser.fromEntity(MyUserEntity.fromDocument(doc['myUser'])));
  }

  @override
  List<Object?> get props => [
        catId,
        catName,
        location,
        age,
        sex,
        color,
        description,
        image,
        isFixed,
        isAdopted,
        myUser
      ];

  @override
  String toString() {
    return '''CatEntity: {
      catId: $catId
      catName: $catName
       location: $location
      age: $age
      sex: $sex
      color: $color
      description: $description
      image: $image
      isFixed: $isFixed
      isAdopted: $isAdopted
      myUser: $myUser
    }''';
  }
}
