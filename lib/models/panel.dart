class Admin {
  String? id;
  String? name;
  String? email;
  String? role; // e.g., "Manager", "Staff"
  String? phoneNumber;
  String? profilePictureUrl;

  Admin({
    id,
    name,
    email,
    role,
    phoneNumber,
    profilePictureUrl,
  });

  Admin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    phoneNumber = json['phone_number'];
    profilePictureUrl = json['profile_picture_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['phone_number'] = phoneNumber;
    data['profile_picture_url'] = profilePictureUrl;
    return data;
  }
}
