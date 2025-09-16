import 'dart:io';

class VerifyRequest {
  String userId;
  File image;
  String metric; // default "cosine"
  double? threshold; // null => biarkan default backend

  VerifyRequest({
    required this.userId,
    required this.image,
    this.metric = 'cosine',
    this.threshold,
  });

  /// Hanya field non-file (untuk JSON/debug); upload tetap pakai multipart.
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'metric': metric,
    if (threshold != null) 'threshold': threshold,
  };

  /// Form fields (tanpa file) untuk multipart
  Map<String, String> toFormFields() => {
    'user_id': userId,
    'metric': metric,
    if (threshold != null) 'threshold': threshold!.toString(),
  };
}

class VerifyResponse {
  bool? isMatch;
  double? score;
  String? metric;
  double? threshold;
  String? message;
  bool? success;

  VerifyResponse({
    this.isMatch,
    this.score,
    this.metric,
    this.threshold,
    this.message,
    this.success,
  });

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      return null;
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return VerifyResponse(
      isMatch: parseBool(json['is_match'] ?? json['matched'] ?? json['match']),
      score: parseDouble(
        json['score'] ?? json['distance'] ?? json['similarity'],
      ),
      metric: (json['metric'] ?? json['method'])?.toString(),
      threshold: parseDouble(json['threshold']),
      message: json['message']?.toString(),
      success: json['success'] is bool ? json['success'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (isMatch != null) 'is_match': isMatch,
    if (score != null) 'score': score,
    if (metric != null) 'metric': metric,
    if (threshold != null) 'threshold': threshold,
    if (message != null) 'message': message,
    if (success != null) 'success': success,
  };
}
