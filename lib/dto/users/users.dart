class Users {
  // Wajib
  final String idUser;
  final String namaPengguna;
  final String email;
  final String role;

  // Boleh null
  final String? kontak;
  final String? agama;
  final String? fotoProfilUser;
  final DateTime? tanggalLahir;
  final String? idDepartement;
  final String? idLocation;
  final Departement? departement;
  final Kantor? kantor;

  // Tanggal sistem: kita jaga supaya TIDAK null (fallback ke now())
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.idUser,
    required this.namaPengguna,
    required this.email,
    required this.role,
    this.kontak,
    this.agama,
    this.fotoProfilUser,
    this.tanggalLahir,
    this.idDepartement,
    this.idLocation,
    required this.createdAt,
    required this.updatedAt,
    this.departement,
    this.kantor,
  });

  // Helpers pembersih nilai
  static String? _s(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  static DateTime? _d(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    // Ambil tanggal sistem dengan fallback aman
    final created =
        _d(json['created_at']) ?? _d(json['createdAt']) ?? DateTime.now();
    final updated = _d(json['updated_at']) ?? _d(json['updatedAt']) ?? created;

    return Users(
      idUser: (json['id_user'] ?? json['idUser']).toString(),
      namaPengguna: (json['nama_pengguna'] ?? json['namaPengguna']).toString(),
      email: (json['email']).toString(),
      role: (json['role']).toString(),

      kontak: _s(json['kontak']),
      agama: _s(json['agama']),
      // bersihkan "" / "null" jadi null
      fotoProfilUser: _s(json['foto_profil_user']),
      tanggalLahir: _d(json['tanggal_lahir']),

      idDepartement: _s(json['id_departement']),
      idLocation: _s(json['id_location']),

      createdAt: created,
      updatedAt: updated,

      departement: json['departement'] == null
          ? null
          : Departement.fromJson(
              Map<String, dynamic>.from(json['departement']),
            ),
      kantor: json['kantor'] == null
          ? null
          : Kantor.fromJson(Map<String, dynamic>.from(json['kantor'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_user': idUser,
    'nama_pengguna': namaPengguna,
    'email': email,
    'role': role,

    if (kontak != null) 'kontak': kontak,
    if (agama != null) 'agama': agama,
    'foto_profil_user': fotoProfilUser,
    'tanggal_lahir': tanggalLahir?.toIso8601String(),

    'id_departement': idDepartement,
    'id_location': idLocation,

    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),

    'departement': departement?.toJson(),
    'kantor': kantor?.toJson(),
  };
}

class Departement {
  final String idDepartement;
  final String namaDepartement;

  Departement({required this.idDepartement, required this.namaDepartement});

  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
    idDepartement: (json['id_departement'] ?? json['idDepartement']).toString(),
    namaDepartement: (json['nama_departement'] ?? json['namaDepartement'])
        .toString(),
  );

  Map<String, dynamic> toJson() => {
    'id_departement': idDepartement,
    'nama_departement': namaDepartement,
  };
}

class Kantor {
  final String idLocation;
  final String namaKantor;

  Kantor({required this.idLocation, required this.namaKantor});

  factory Kantor.fromJson(Map<String, dynamic> json) => Kantor(
    idLocation: (json['id_location'] ?? json['idLocation']).toString(),
    namaKantor: (json['nama_kantor'] ?? json['namaKantor']).toString(),
  );

  Map<String, dynamic> toJson() => {
    'id_location': idLocation,
    'nama_kantor': namaKantor,
  };
}
