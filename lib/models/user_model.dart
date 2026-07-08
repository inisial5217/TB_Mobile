// model user e-commerce
class UserModel {
  final String id; // param user id
  final String email; // param email
  final String fullName; // param nama lengkap
  final String? phone; // param telepon opsional
  final String? avatarUrl; // param url avatar
  final RoleModel? role; // param role user

  // constructor init
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.role,
  });

  // object to map dari json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'No Name',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'])
          : null,
    );
  }

  // konversi ke json
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }

  // cek apakah user adalah admin
  bool get isAdmin => role?.name?.toLowerCase() == 'admin';
}

// model role user
class RoleModel {
  final String? id;
  final String? name;
  final String? description;

  RoleModel({this.id, this.name, this.description});

  // parse json role
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
