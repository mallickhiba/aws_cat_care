import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? picture;

  const MyUserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.picture,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'picture': picture,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      id: doc['id'],
      email: doc['email'],
      name: doc['name'],
      role: doc['role'],
      picture: doc['picture'],
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, email, name, role, picture];

  @override
  String toString() {
    return '''MyUserEntity { id: $id, email: $email, name: $name, role: $role, picture: $picture }''';
  }
}
