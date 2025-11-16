import 'dart:convert';

KategoriIzinJam kategoriIzinJamFromJson(String str) => KategoriIzinJam.fromJson(json.decode(str));

String kategoriIzinJamToJson(KategoriIzinJam data) => json.encode(data.toJson());

class KategoriIzinJam {
    List<Data> data;
    Pagination pagination;

    KategoriIzinJam({
        required this.data,
        required this.pagination,
    });

    factory KategoriIzinJam.fromJson(Map<String, dynamic> json) => KategoriIzinJam(
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
    };
}

class Data {
    String idKategoriIzinJam;
    String namaKategori;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    Data({
        required this.idKategoriIzinJam,
        required this.namaKategori,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        idKategoriIzinJam: json["id_kategori_izin_jam"],
        namaKategori: json["nama_kategori"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id_kategori_izin_jam": idKategoriIzinJam,
        "nama_kategori": namaKategori,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
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
