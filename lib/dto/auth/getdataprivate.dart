import 'package:e_hrm/dto/users/users.dart';

class Getdataprivate {
  final String idUser;
  final String namaPengguna;
  final String email;
  final String role;

  // ⇩ ubah jadi nullable
  final DateTime? tanggalLahir;
  final String? kontak;
  final String? fotoProfilUser;
  final String? idDepartement; // was String
  final String? idLocation; // was String
  final DateTime? passwordUpdatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⇩ nested juga nullable (karena respons kamu null)
  final Departement? departement; // was non-null
  final Kantor? kantor; // was non-null

  Getdataprivate({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    this.tanggalLahir,
    this.kontak,
    this.fotoProfilUser,
    this.idDepartement,
    this.idLocation,
    this.passwordUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.departement,
    this.kantor,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  factory Getdataprivate.fromJson(Map<String, dynamic> json) => Getdataprivate(
    idUser: json["id_user"] as String,
    namaPengguna: json["nama_pengguna"] as String,
    email: json["email"] as String,
    role: json["role"] as String,
    tanggalLahir: _parseDate(json["tanggal_lahir"]),
    kontak: json["kontak"] as String?,
    fotoProfilUser: json["foto_profil_user"] as String?,
    idDepartement: json["id_departement"] as String?,
    idLocation: json["id_location"] as String?,
    passwordUpdatedAt: _parseDate(json["password_updated_at"]),
    createdAt: _parseDate(json["created_at"]),
    updatedAt: _parseDate(json["updated_at"]),
    departement: (json["departement"] is Map<String, dynamic>)
        ? Departement.fromJson(json["departement"])
        : null,
    kantor: (json["kantor"] is Map<String, dynamic>)
        ? Kantor.fromJson(json["kantor"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "role": role,
    if (tanggalLahir != null) "tanggal_lahir": tanggalLahir!.toIso8601String(),
    if (kontak != null) "kontak": kontak,
    if (fotoProfilUser != null) "foto_profil_user": fotoProfilUser,
    if (idDepartement != null) "id_departement": idDepartement,
    if (idLocation != null) "id_location": idLocation,
    if (passwordUpdatedAt != null)
      "password_updated_at": passwordUpdatedAt!.toIso8601String(),
    if (createdAt != null) "created_at": createdAt!.toIso8601String(),
    if (updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
    if (departement != null) "departement": departement!.toJson(),
    if (kantor != null) "kantor": kantor!.toJson(),
  };
}
