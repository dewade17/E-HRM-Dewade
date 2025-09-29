import 'dart:convert';

Getdataprivate getdataprivateFromJson(String str) =>
    Getdataprivate.fromJson(json.decode(str));

String getdataprivateToJson(Getdataprivate data) => json.encode(data.toJson());

class Getdataprivate {
  String message;
  User user;

  Getdataprivate({required this.message, required this.user});

  factory Getdataprivate.fromJson(Map<String, dynamic> json) => Getdataprivate(
    message: json["message"],
    user: User.fromJson(json["user"]),
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
  String idLocation;
  DateTime passwordUpdatedAt;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic departement;
  Kantor kantor;

  User({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    required this.tanggalLahir,
    required this.kontak,
    required this.fotoProfilUser,
    required this.idDepartement,
    required this.idLocation,
    required this.passwordUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.departement,
    required this.kantor,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    role: json["role"],
    tanggalLahir: json["tanggal_lahir"],
    kontak: json["kontak"],
    fotoProfilUser: json["foto_profil_user"],
    idDepartement: json["id_departement"],
    idLocation: json["id_location"],
    passwordUpdatedAt: DateTime.parse(json["password_updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    departement: json["departement"],
    kantor: Kantor.fromJson(json["kantor"]),
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
    "password_updated_at": passwordUpdatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "departement": departement,
    "kantor": kantor.toJson(),
  };
}

class Kantor {
  String idLocation;
  String namaKantor;
  String latitude;
  String longitude;
  int radius;

  Kantor({
    required this.idLocation,
    required this.namaKantor,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory Kantor.fromJson(Map<String, dynamic> json) => Kantor(
    idLocation: json["id_location"],
    namaKantor: json["nama_kantor"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    radius: json["radius"],
  );

  Map<String, dynamic> toJson() => {
    "id_location": idLocation,
    "nama_kantor": namaKantor,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
  };
}
