import 'dart:convert';

Absensicheckout absensicheckoutFromJson(String str) =>
    Absensicheckout.fromJson(json.decode(str));

String absensicheckoutToJson(Absensicheckout data) =>
    json.encode(data.toJson());

class Absensicheckout {
  bool? accepted;
  int? distanceMeters;
  bool? match;
  String? message;
  String? metric;
  bool? ok;
  double? score;
  String? taskId;
  double? threshold;
  String? userId;

  Absensicheckout({
    this.accepted,
    this.distanceMeters,
    this.match,
    this.message,
    this.metric,
    this.ok,
    this.score,
    this.taskId,
    this.threshold,
    this.userId,
  });

  factory Absensicheckout.fromJson(Map<String, dynamic> json) =>
      Absensicheckout(
        accepted: json["accepted"],
        distanceMeters: json["distanceMeters"],
        match: json["match"],
        message: json["message"],
        metric: json["metric"],
        ok: json["ok"],
        score: json["score"]?.toDouble(),
        taskId: json["task_id"],
        threshold: json["threshold"]?.toDouble(),
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
    "accepted": accepted,
    "distanceMeters": distanceMeters,
    "match": match,
    "message": message,
    "metric": metric,
    "ok": ok,
    "score": score,
    "task_id": taskId,
    "threshold": threshold,
    "user_id": userId,
  };
}
