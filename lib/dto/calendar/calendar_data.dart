import 'dart:convert';

CalendarResponse calendarResponseFromJson(String str) =>
    CalendarResponse.fromJson(json.decode(str));

class CalendarResponse {
  bool ok;
  List<CalendarItem> data;
  Meta meta;

  CalendarResponse({required this.ok, required this.data, required this.meta});

  factory CalendarResponse.fromJson(Map<String, dynamic> json) =>
      CalendarResponse(
        ok: json["ok"] ?? false,
        data: json["data"] == null
            ? []
            : List<CalendarItem>.from(
                json["data"].map((x) => CalendarItem.fromJson(x)),
              ),
        meta: Meta.fromJson(json["meta"] ?? {}),
      );
}

class CalendarItem {
  String type;
  String id;
  String userId;
  String title;
  String? description;
  String? status;
  DateTime start;
  DateTime end;

  CalendarItem({
    required this.type,
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.status,
    required this.start,
    required this.end,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) => CalendarItem(
    type: json["type"] ?? '',
    id: json["id"]?.toString() ?? '',
    userId: json["user_id"]?.toString() ?? '',
    title: json["title"] ?? '',
    description: json["description"],
    status: json["status"],
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
  );
}

class Meta {
  int page;
  int perPage;
  int total;
  int totalPages;

  Meta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: json["page"] ?? 1,
    perPage: json["perPage"] ?? 20,
    total: json["total"] ?? 0,
    totalPages: json["totalPages"] ?? 0,
  );
}
