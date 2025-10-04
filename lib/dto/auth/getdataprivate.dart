import 'dart:convert';

Getdataprivate getdataprivateFromJson(String str) =>
    Getdataprivate.fromJson(json.decode(str));

String getdataprivateToJson(Getdataprivate data) => json.encode(data.toJson());

class Getdataprivate {
  String message;
  User user;

  Getdataprivate({required this.message, required this.user});

  factory Getdataprivate.fromJson(Map<String, dynamic> json) => Getdataprivate(
    message: json["message"] as String? ?? '',
    user: User.fromJson(
      (json["user"] as Map<String, dynamic>?) ?? <String, dynamic>{},
    ),
  );

  Map<String, dynamic> toJson() => {"message": message, "user": user.toJson()};
}

class User {
  String idUser;
  String namaPengguna;
  String email;
  String role;
  dynamic tanggalLahir;
  dynamic kontak;
  dynamic fotoProfilUser;
  dynamic idDepartement;
  String? idLocation;
  DateTime? passwordUpdatedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic departement;
  Kantor? kantor;

  User({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.tanggalLahir,
    required this.kontak,
    required this.fotoProfilUser,
    required this.idDepartement,
    this.idLocation,
    this.passwordUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.departement,
    this.kantor,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"] as String? ?? '',
    namaPengguna: json["nama_pengguna"] as String? ?? '',
    email: json["email"] as String? ?? '',
    role: json["role"] as String? ?? '',
    tanggalLahir: json["tanggal_lahir"],
    kontak: json["kontak"],
    fotoProfilUser: json["foto_profil_user"],
    idDepartement: json["id_departement"],
    idLocation: json["id_location"] as String?,
    passwordUpdatedAt: (json["password_updated_at"] as String?) != null
        ? DateTime.parse(json["password_updated_at"] as String)
        : null,
    createdAt: (json["created_at"] as String?) != null
        ? DateTime.parse(json["created_at"] as String)
        : null,
    updatedAt: (json["updated_at"] as String?) != null
        ? DateTime.parse(json["updated_at"] as String)
        : null,
    departement: json["departement"],
    kantor: json["kantor"] != null
        ? Kantor.fromJson(json["kantor"] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    "tanggal_lahir": tanggalLahir,
    "kontak": kontak,
    "foto_profil_user": fotoProfilUser,
    "id_departement": idDepartement,
    "id_location": idLocation,
    "password_updated_at": passwordUpdatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "departement": departement,
    "kantor": kantor?.toJson(),
  };
}

class Kantor {
  String? idLocation;
  String? namaKantor;
  String? latitude;
  String? longitude;
  int? radius;

  Kantor({
    this.idLocation,
    this.namaKantor,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory Kantor.fromJson(Map<String, dynamic> json) => Kantor(
    idLocation: json["id_location"] as String?,
    namaKantor: json["nama_kantor"] as String?,
    latitude: json["latitude"] as String?,
    longitude: json["longitude"] as String?,
    radius: json["radius"] is int
        ? json["radius"] as int
        : (json["radius"] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    "id_location": idLocation,
    "nama_kantor": namaKantor,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
  };
}
