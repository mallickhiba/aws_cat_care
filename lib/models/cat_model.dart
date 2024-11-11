class CatModel {
  String? id;
  String? name;
  String? location;
  String? sex;
  int? age;
  bool? isFixed;
  bool? isAdopted;
  String? color;
  String? imageUrl;
  String? description;

  CatModel(
      {this.id,
      this.name,
      this.location,
      this.sex,
      this.age,
      this.isFixed,
      this.color,
      this.imageUrl,
      this.description});

  CatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    sex = json['sex'];
    age = json['age'];
    isFixed = json['is_fixed'];
    color = json['color'];
    imageUrl = json['image_url'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['sex'] = sex;
    data['age'] = age;
    data['is_fixed'] = isFixed;
    data['color'] = color;
    data['image_url'] = imageUrl;
    data['description'] = description;
    return data;
  }
}
