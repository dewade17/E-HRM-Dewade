// To parse this JSON data, do
//
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';

List<Notification> notificationFromJson(String str) => List<Notification>.from(
  json.decode(str).map((x) => Notification.fromJson(x)),
);

String notificationToJson(List<Notification> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Notification {
  String id;
  String eventTrigger;
  String description;
  String titleTemplate;
  String bodyTemplate;
  String placeholders;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Notification({
    required this.id,
    required this.eventTrigger,
    required this.description,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.placeholders,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["id"],
    eventTrigger: json["eventTrigger"],
    description: json["description"],
    titleTemplate: json["titleTemplate"],
    bodyTemplate: json["bodyTemplate"],
    placeholders: json["placeholders"],
    isActive: json["isActive"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "eventTrigger": eventTrigger,
    "description": description,
    "titleTemplate": titleTemplate,
    "bodyTemplate": bodyTemplate,
    "placeholders": placeholders,
    "isActive": isActive,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
