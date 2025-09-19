import 'dart:convert';

ApproversAbsensi approversAbsensiFromJson(String str) =>
    ApproversAbsensi.fromJson(json.decode(str));

String approversAbsensiToJson(ApproversAbsensi data) =>
    json.encode(data.toJson());

class ApproversAbsensi {
  List<User> users;
  Pagination pagination;
  Filters filters;

  ApproversAbsensi({
    required this.users,
    required this.pagination,
    required this.filters,
  });

  factory ApproversAbsensi.fromJson(Map<String, dynamic> json) =>
      ApproversAbsensi(
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
        filters: Filters.fromJson(json["filters"]),
      );

  Map<String, dynamic> toJson() => {
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
    "filters": filters.toJson(),
  };
}

class Filters {
  List<String> roles;

  Filters({required this.roles});

  factory Filters.fromJson(Map<String, dynamic> json) =>
      Filters(roles: List<String>.from(json["roles"].map((x) => x)));

  Map<String, dynamic> toJson() => {
    "roles": List<dynamic>.from(roles.map((x) => x)),
  };
}

class Pagination {
  int page;
  int pageSize;
  int total;
  int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    pageSize: json["pageSize"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "pageSize": pageSize,
    "total": total,
    "totalPages": totalPages,
  };
}

class User {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  dynamic fotoProfilUser;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.fotoProfilUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    role: json["role"],
    fotoProfilUser: json["foto_profil_user"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    "foto_profil_user": fotoProfilUser,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
