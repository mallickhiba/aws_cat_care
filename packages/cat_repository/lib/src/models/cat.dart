import 'package:user_repository/user_repository.dart';

import '../entities/entities.dart';

class Cat {
  String catId;
  String cat;
  DateTime createAt;
  MyUser myUser;

  Cat({
    required this.catId,
    required this.cat,
    required this.createAt,
    required this.myUser,
  });

  /// Empty user which represents an unauthenticated user.
  static final empty =
      Cat(catId: '', cat: '', createAt: DateTime.now(), myUser: MyUser.empty);

  /// Modify MyUser parameters
  Cat copyWith({
    String? catId,
    String? cat,
    DateTime? createAt,
    MyUser? myUser,
  }) {
    return Cat(
      catId: catId ?? this.catId,
      cat: cat ?? this.cat,
      createAt: createAt ?? this.createAt,
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
      cat: cat,
      createAt: createAt,
      myUser: myUser,
    );
  }

  static Cat fromEntity(CatEntity entity) {
    return Cat(
      catId: entity.catId,
      cat: entity.cat,
      createAt: entity.createAt,
      myUser: entity.myUser,
    );
  }

  @override
  String toString() {
    return '''Cat: {
      catId: $catId
      cat: $cat
      createAt: $createAt
      myUser: $myUser
    }''';
  }
}
