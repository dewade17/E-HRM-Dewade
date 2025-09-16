class GetFace {
  int count;
  List<Item> items;
  bool ok;
  String prefix;
  String userId;

  GetFace({
    required this.count,
    required this.items,
    required this.ok,
    required this.prefix,
    required this.userId,
  });

  factory GetFace.fromJson(Map<String, dynamic> json) => GetFace(
    count: json["count"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    ok: json["ok"],
    prefix: json["prefix"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "ok": ok,
    "prefix": prefix,
    "user_id": userId,
  };
}

class Item {
  String name;
  String path;
  String signedUrl;

  Item({required this.name, required this.path, required this.signedUrl});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    name: json["name"],
    path: json["path"],
    signedUrl: json["signed_url"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "path": path,
    "signed_url": signedUrl,
  };
}
