class Departements {
  String idDepartement;
  String namaDepartement;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Departements({
    required this.idDepartement,
    required this.namaDepartement,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Departements.fromJson(Map<String, dynamic> json) => Departements(
    idDepartement: json["id_departement"],
    namaDepartement: json["nama_departement"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_departement": idDepartement,
    "nama_departement": namaDepartement,
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
