import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  Data data;

  Profile({required this.data});

  factory Profile.fromJson(Map<String, dynamic> json) =>
      Profile(data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"data": data.toJson()};
}

class Data {
  String idUser;
  String namaPengguna;
  String email;
  dynamic alamatDomisili;
  dynamic alamatKtp;
  dynamic kontak;
  dynamic agama;
  dynamic tanggalLahir;
  dynamic golonganDarah;
  dynamic nomorRekening;
  dynamic jenisBank;
  dynamic fotoProfilUser;

  Data({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.alamatDomisili,
    required this.alamatKtp,
    required this.kontak,
    required this.agama,
    required this.tanggalLahir,
    required this.golonganDarah,
    required this.nomorRekening,
    required this.jenisBank,
    required this.fotoProfilUser,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idUser: json["id_user"],
    namaPengguna: json["nama_pengguna"],
    email: json["email"],
    alamatDomisili: json["alamat_domisili"],
    alamatKtp: json["alamat_ktp"],
    kontak: json["kontak"],
    agama: json["agama"],
    tanggalLahir: json["tanggal_lahir"],
    golonganDarah: json["golongan_darah"],
    nomorRekening: json["nomor_rekening"],
    jenisBank: json["jenis_bank"],
    fotoProfilUser: json["foto_profil_user"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama_pengguna": namaPengguna,
    "email": email,
    "alamat_domisili": alamatDomisili,
    "alamat_ktp": alamatKtp,
    "kontak": kontak,
    "agama": agama,
    "tanggal_lahir": tanggalLahir,
    "golongan_darah": golonganDarah,
    "nomor_rekening": nomorRekening,
    "jenis_bank": jenisBank,
    "foto_profil_user": fotoProfilUser,
  };
}
