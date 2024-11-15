import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/entities.dart';

class MyUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? picture;

  const MyUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.picture,
  });

  static var empty =
      const MyUser(id: '', email: '', name: '', role: '', picture: '');

  MyUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? picture,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      picture: picture ?? this.picture,
    );
  }

  bool get isEmpty {
    return this == MyUser.empty;
  }

  bool get isNotEmpty {
    return this != MyUser.empty;
  }

  MyUserEntity toEntity() {
    return MyUserEntity(
      id: id,
      email: email,
      name: name,
      role: role,
      picture: picture,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      picture: entity.picture,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, email, name, role, picture];
}
