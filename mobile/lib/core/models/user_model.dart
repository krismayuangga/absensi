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
    try {
      return UserModel(
        id: _parseInt(json['id']),
        employeeId: json['employee_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        birthDate: json['birth_date']?.toString(),
        gender: json['gender']?.toString(),
        address: json['address']?.toString(),
        avatar: json['avatar']?.toString(),
        role: json['role']?.toString() ?? 'employee',
        status: json['status']?.toString() ??
            (json['is_active'] == true ? 'active' : 'inactive'),
        department: _parseDepartment(json['department']),
        position: _parsePosition(json['position']),
        company: _parseCompany(json['company']),
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static Department? _parseDepartment(dynamic dept) {
    try {
      if (dept == null) return null;
      if (dept is String) {
        return Department(id: 0, name: dept);
      }
      if (dept is Map<String, dynamic>) {
        return Department.fromJson(dept);
      }
      if (dept is Map) {
        return Department.fromJson(Map<String, dynamic>.from(dept));
      }
      return null;
    } catch (e) {
      print('Error parsing Department: $e');
      return null;
    }
  }

  static Position? _parsePosition(dynamic pos) {
    try {
      if (pos == null) return null;
      if (pos is String) {
        return Position(id: 0, name: pos, level: 1);
      }
      if (pos is Map<String, dynamic>) {
        return Position.fromJson(pos);
      }
      if (pos is Map) {
        return Position.fromJson(Map<String, dynamic>.from(pos));
      }
      return null;
    } catch (e) {
      print('Error parsing Position: $e');
      return null;
    }
  }

  static Company? _parseCompany(dynamic comp) {
    try {
      if (comp == null) return null;
      if (comp is Map<String, dynamic>) {
        return Company.fromJson(comp);
      }
      if (comp is Map) {
        return Company.fromJson(Map<String, dynamic>.from(comp));
      }
      return null;
    } catch (e) {
      print('Error parsing Company: $e');
      return null;
    }
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
    try {
      return Department(
        id: _parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
    } catch (e) {
      print('Error parsing Department: $e');
      return Department(id: 0, name: 'Unknown');
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
    try {
      return Position(
        id: _parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        level: _parseInt(json['level']) == 0 ? 1 : _parseInt(json['level']),
      );
    } catch (e) {
      print('Error parsing Position: $e');
      return Position(id: 0, name: 'Unknown', level: 1);
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
    try {
      return Company(
        id: _parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        logo: json['logo']?.toString(),
      );
    } catch (e) {
      print('Error parsing Company: $e');
      return Company(id: 0, name: 'Unknown', email: '');
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
