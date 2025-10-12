class Absensi {
  int distanceMeters;
  bool match;
  String metric;
  String mode;
  bool ok;
  int recipientsAdded;
  double score;
  double threshold;
  int todosCreated;
  String userId;

  Absensi({
    required this.distanceMeters,
    required this.match,
    required this.metric,
    required this.mode,
    required this.ok,
    required this.recipientsAdded,
    required this.score,
    required this.threshold,
    required this.todosCreated,
    required this.userId,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
    distanceMeters: json["distanceMeters"],
    match: json["match"],
    metric: json["metric"],
    mode: json["mode"],
    ok: json["ok"],
    recipientsAdded: json["recipientsAdded"],
    score: json["score"].toDouble(),
    threshold: json["threshold"].toDouble(),
    todosCreated: json["todosCreated"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "distanceMeters": distanceMeters,
    "match": match,
    "metric": metric,
    "mode": mode,
    "ok": ok,
    "recipientsAdded": recipientsAdded,
    "score": score,
    "threshold": threshold,
    "todosCreated": todosCreated,
    "user_id": userId,
  };
}
