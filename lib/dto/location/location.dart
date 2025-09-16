class Location {
  String idLocation;
  String namaKantor;
  String latitude;
  String longitude;
  int radius;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Location({
    required this.idLocation,
    required this.namaKantor,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    idLocation: json["id_location"],
    namaKantor: json["nama_kantor"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    radius: json["radius"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_location": idLocation,
    "nama_kantor": namaKantor,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
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
