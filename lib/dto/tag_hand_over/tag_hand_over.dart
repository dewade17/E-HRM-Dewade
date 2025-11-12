// To parse this JSON data, do
//
//     final tagHandOver = tagHandOverFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

TagHandOver tagHandOverFromJson(String str) =>
    TagHandOver.fromJson(json.decode(str));

String tagHandOverToJson(TagHandOver data) => json.encode(data.toJson());

class TagHandOver {
  List<Data> data;
  Pagination pagination;

  TagHandOver({required this.data, required this.pagination});

  factory TagHandOver.fromJson(Map<String, dynamic> json) => TagHandOver(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Data {
  String idUser;
  String namaPengguna;
  String email;
  String kontak;
  String fotoProfilUser;
  dynamic divisi;
  String idDepartement;
  Departement departement;
  String role;

  Data({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.kontak,
    required this.fotoProfilUser,
    required this.divisi,
    required this.idDepartement,
    required this.departement,
    required this.role,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    kontak: json["kontak"],
    fotoProfilUser: json["foto_profil_user"],
    divisi: json["divisi"],
    idDepartement: json["id_departement"],
    departement: Departement.fromJson(json["departement"]),
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "kontak": kontak,
    "foto_profil_user": fotoProfilUser,
    "divisi": divisi,
    "id_departement": idDepartement,
    "departement": departement.toJson(),
    "role": role,
  };
}

class Departement {
  String idDepartement;
  String namaDepartement;

  Departement({required this.idDepartement, required this.namaDepartement});

  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
    idDepartement: json["id_departement"],
    namaDepartement: json["nama_departement"],
  );

  Map<String, dynamic> toJson() => {
    "id_departement": idDepartement,
    "nama_departement": namaDepartement,
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
