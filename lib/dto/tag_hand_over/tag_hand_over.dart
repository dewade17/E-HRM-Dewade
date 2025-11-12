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
  String? kontak;
  String? fotoProfilUser;
  String? divisi;
  String? idDepartement;
  Departement? departement;
  String role;

  Data({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    this.kontak,
    this.fotoProfilUser,
    this.divisi,
    this.idDepartement,
    this.departement,
    required this.role,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    kontak: _nullableString(json["kontak"]),
    fotoProfilUser: _nullableString(json["foto_profil_user"]),
    divisi: _nullableString(json["divisi"]),
    idDepartement: _nullableString(json["id_departement"]),
    departement: json["departement"] == null
        ? null
        : Departement.fromJson(json["departement"]),
    role: json["role"],
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "id_user": idUser,
      "nama_pengguna": namaPengguna,
      "email": email,
      "role": role,
    };

    if (kontak != null) {
      map["kontak"] = kontak;
    }
    if (fotoProfilUser != null) {
      map["foto_profil_user"] = fotoProfilUser;
    }
    if (divisi != null) {
      map["divisi"] = divisi;
    }
    if (idDepartement != null) {
      map["id_departement"] = idDepartement;
    }
    if (departement != null) {
      map["departement"] = departement!.toJson();
    }

    return map;
  }
}

String? _nullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? null : stringValue;
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
