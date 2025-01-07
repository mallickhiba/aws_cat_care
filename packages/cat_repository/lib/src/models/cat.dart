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
  MyUser myUser;
  List<String> incidentIds;
  List<String> photos;
  bool isVaccinated;
  bool isHealthy;
  String campus;
  String status; //lost, deceased, adopted, available

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
    required this.myUser,
    this.incidentIds = const [],
    this.photos = const [],
    required this.isVaccinated,
    required this.isHealthy,
    required this.campus,
    required this.status,
  });

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
      myUser: MyUser.empty,
      incidentIds: [],
      photos: [],
      isVaccinated: false,
      isHealthy: false,
      campus: '',
      status: '');

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
    MyUser? myUser,
    List<String>? incidentIds,
    List<String>? photos,
    bool? isVaccinated,
    bool? isHealthy,
    String? campus,
    String? status,
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
      myUser: myUser ?? this.myUser,
      incidentIds: incidentIds ?? this.incidentIds,
      photos: photos ?? this.photos,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isHealthy: isHealthy ?? this.isHealthy,
      campus: campus ?? this.campus,
      status: status ?? this.status,
    );
  }

  bool get isEmpty => this == Cat.empty;

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
      myUser: myUser,
      incidentIds: incidentIds,
      photos: photos,
      isVaccinated: isVaccinated,
      isHealthy: isHealthy,
      campus: campus,
      status: status,
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
      myUser: entity.myUser,
      incidentIds: entity.incidentIds,
      photos: entity.photos,
      isVaccinated: entity.isVaccinated,
      isHealthy: entity.isHealthy,
      campus: entity.campus,
      status: entity.status,
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
      myUser: $myUser
      incidentIds: $incidentIds
      photos: $photos
      isVaccinated: $isVaccinated
      isHealthy: $isHealthy
      campus: $campus
      status: $status
    }''';
  }

  toDocument() {}

  static fromDocument(Map<String, dynamic> json) {}
}
