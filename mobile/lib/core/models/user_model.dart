class UserModel {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? avatar;
  final String role;
  final String status;
  final Department? department;
  final Position? position;
  final Company? company;

  UserModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.address,
    this.avatar,
    required this.role,
    required this.status,
    this.department,
    this.position,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      address: json['address'],
      avatar: json['avatar'],
      role: json['role'] ?? 'employee',
      status:
          json['status'] ?? (json['is_active'] == true ? 'active' : 'inactive'),
      department: json['department'] != null && json['department'] is Map
          ? Department.fromJson(Map<String, dynamic>.from(json['department']))
          : json['department'] is String
              ? Department(id: 0, name: json['department'])
              : null,
      position: json['position'] != null && json['position'] is Map
          ? Position.fromJson(Map<String, dynamic>.from(json['position']))
          : json['position'] is String
              ? Position(id: 0, name: json['position'], level: 1)
              : null,
      company: json['company'] != null && json['company'] is Map
          ? Company.fromJson(Map<String, dynamic>.from(json['company']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'address': address,
      'avatar': avatar,
      'role': role,
      'status': status,
      'department': department?.toJson(),
      'position': position?.toJson(),
      'company': company?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? employeeId,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? address,
    String? avatar,
    String? role,
    String? status,
    Department? department,
    Position? position,
    Company? company,
  }) {
    return UserModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      department: department ?? this.department,
      position: position ?? this.position,
      company: company ?? this.company,
    );
  }

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isHR => role == 'hr';
  bool get isEmployee => role == 'employee';
}

class Department {
  final int id;
  final String name;
  final String? description;

  Department({
    required this.id,
    required this.name,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Position {
  final int id;
  final String name;
  final String? description;
  final int level;

  Position({
    required this.id,
    required this.name,
    this.description,
    required this.level,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
    };
  }
}

class Company {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? logo;

  Company({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'logo': logo,
    };
  }
}
