import 'package:user_repository/user_repository.dart';

import '../entities/entities.dart';

class Cat {
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

  Cat({
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

  /// Empty user which represents an unauthenticated user.
  static final empty = Cat(
      catId: '',
      catName: '',
      location: '',
      age: 0,
      sex: '',
      color: '',
      description: '',
      image: '',
      isFixed: false,
      isAdopted: false,
      myUser: MyUser.empty);

  /// Modify MyUser parameters
  Cat copyWith({
    String? catId,
    String? catName,
    String? location,
    int? age,
    String? sex,
    String? color,
    String? description,
    String? image,
    bool? isFixed,
    bool? isAdopted,
    MyUser? myUser,
  }) {
    return Cat(
      catId: catId ?? this.catId,
      catName: catName ?? this.catName,
      location: location ?? this.location,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      color: color ?? this.color,
      description: description ?? this.description,
      image: image ?? this.image,
      isFixed: isFixed ?? this.isFixed,
      isAdopted: isAdopted ?? this.isAdopted,
      myUser: myUser ?? this.myUser,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == Cat.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != Cat.empty;

  CatEntity toEntity() {
    return CatEntity(
      catId: catId,
      catName: catName,
      location: location,
      age: age,
      sex: sex,
      color: color,
      description: description,
      image: image,
      isFixed: isFixed,
      isAdopted: isAdopted,
      myUser: myUser,
    );
  }

  static Cat fromEntity(CatEntity entity) {
    return Cat(
      catId: entity.catId,
      catName: entity.catName,
      location: entity.location,
      age: entity.age,
      sex: entity.sex,
      color: entity.color,
      description: entity.description,
      image: entity.image,
      isFixed: entity.isFixed,
      isAdopted: entity.isAdopted,
      myUser: entity.myUser,
    );
  }

  @override
  String toString() {
    return '''Cat: {
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
