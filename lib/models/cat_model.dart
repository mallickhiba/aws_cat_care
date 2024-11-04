class Cat {
  String? id;
  String? name;
  String? breed;
  int? age;
  String? color;
  String? imageUrl;

  Cat({
    this.id,
    this.name,
    this.breed,
    this.age,
    this.color,
    this.imageUrl,
  });

  Cat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    breed = json['breed'];
    age = json['age'];
    color = json['color'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['breed'] = breed;
    data['age'] = age;
    data['color'] = color;
    data['image_url'] = imageUrl;
    return data;
  }
}
