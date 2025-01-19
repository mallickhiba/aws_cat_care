part of 'create_cat_bloc.dart';

abstract class CreateCatEvent extends Equatable {
  const CreateCatEvent();

  @override
  List<Object> get props => [];
}

class CreateCat extends CreateCatEvent {
  final Cat cat;
  const CreateCat(this.cat);
}

class UpdateCatDetails extends CreateCatEvent {
  final String name;
  final int age;
  final String description;
  final String color;
  final bool isFixed;
  final bool isVaccinated;
  final bool isHealthy;
  final String location;
  final String campus;
  final String status;
  final String sex;
  final List<String> photoUrls;

  UpdateCatDetails({
    this.name = '',
    this.age = 0,
    this.description = '',
    this.color = '',
    this.isFixed = false,
    this.isVaccinated = false,
    this.isHealthy = true,
    this.location = '',
    this.campus = '',
    this.status = '',
    this.sex = '',
    this.photoUrls = const [],
  });

  @override
  List<Object> get props => [
        name,
        age,
        description,
        color,
        isFixed,
        isVaccinated,
        isHealthy,
        location,
        campus,
        status,
        sex,
        photoUrls
      ];
}
