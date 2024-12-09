import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class CatEntity {
  String catId;
  String cat;
  DateTime createAt;
  MyUser myUser;

  CatEntity({
    required this.catId,
    required this.cat,
    required this.createAt,
    required this.myUser,
  });

  Map<String, Object?> toDocument() {
    return {
      'catId': catId,
      'cat': cat,
      'createAt': createAt,
      'myUser': myUser.toEntity().toDocument(),
    };
  }

  static CatEntity fromDocument(Map<String, dynamic> doc) {
    return CatEntity(
        catId: doc['catId'] as String,
        cat: doc['cat'] as String,
        createAt: (doc['createAt'] as Timestamp).toDate(),
        myUser: MyUser.fromEntity(MyUserEntity.fromDocument(doc['myUser'])));
  }

  @override
  List<Object?> get props => [catId, cat, createAt, myUser];

  @override
  String toString() {
    return '''CatEntity: {
      catId: $catId
      cat: $cat
      createAt: $createAt
      myUser: $myUser
    }''';
  }
}
