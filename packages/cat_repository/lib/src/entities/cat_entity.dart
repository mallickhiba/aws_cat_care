import 'package:cloud_firestore/cloud_firestore.dart';
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
  MyUser myUser;
  List<String> incidentIds;
  List<String> photos;
  bool isVaccinated;
  bool isHealthy;
  String campus;
  String status; //lost, deceased, adopted, available

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
    required this.myUser,
    this.incidentIds = const [],
    this.photos = const [],
    required this.isVaccinated,
    required this.isHealthy,
    required this.campus,
    required this.status,
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
      'myUser': myUser.toEntity().toDocument(),
      'incidentIds': incidentIds,
      'photos': photos,
      'isVaccinated': isVaccinated,
      'isHealthy': isHealthy,
      'campus': campus,
      'status': status,
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
      myUser: MyUser.fromEntity(MyUserEntity.fromDocument(doc['myUser'])),
      incidentIds: doc['incidentIds'] != null
          ? List<String>.from(doc['incidentIds'] as List)
          : [],
      photos:
          doc['photos'] != null ? List<String>.from(doc['photos'] as List) : [],
      isVaccinated: doc['isVaccinated'] as bool,
      isHealthy: doc['isHealthy'] as bool,
      campus: doc['campus'] as String,
      status: doc['status'] as String,
    );
  }

  static CatEntity fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromDocument(data);
  }

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
        myUser,
        incidentIds,
        photos,
        isVaccinated,
        isHealthy,
        campus,
        status,
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
      myUser: $myUser
      incidentIds: $incidentIds
      photos: $photos
      isVaccinated: $isVaccinated
      isHealthy: $isHealthy
      campus: $campus
      status: $status
    }''';
  }
}
