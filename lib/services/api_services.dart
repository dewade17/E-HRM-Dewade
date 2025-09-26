// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Uri _parseUrl(String url) {
    final s = url.trim();
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      throw ArgumentError('Harus kirim URL absolut, bukan path relatif: $s');
    }
    return Uri.parse(s);
  }

  Future<Map<String, dynamic>> fetchDataPrivate(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found. Please login again.');

    final res = await http.get(
      _parseUrl(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      return jsonDecode(decoded);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized. Please login again.');
    } else {
      print("API Error FETCH DATA [${res.statusCode}]: ${res.body}");
      throw Exception('Failed to load data from $url');
    }
  }

  Future<Map<String, dynamic>> postDataPrivate(
    String url,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.post(
      _parseUrl(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to post data');
    }
  }

  Future<Map<String, dynamic>> updateDataPrivate(
    String url,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      _parseUrl(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to update data');
    }
  }

  Future<Map<String, dynamic>> deleteDataPrivate(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      _parseUrl(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to delete data');
    }
  }

  Future<Map<String, dynamic>> post(
    Map<String, dynamic> data,
    String url,
  ) async {
    final res = await http.post(
      _parseUrl(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = utf8.decode(res.bodyBytes);
      return jsonDecode(decoded);
    } else {
      throw Exception(
        'Failed (${res.statusCode}): ${res.body.isEmpty ? 'No body' : res.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String token, String url) async {
    final res = await http.get(
      _parseUrl(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return body['user'];
    } else {
      print('Get user profile failed: ${res.statusCode}');
      return null;
    }
  }

  Future<List<dynamic>> fetchListPrivate(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found. Please login again.');

    final res = await http.get(
      _parseUrl(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final decoded = utf8.decode(res.bodyBytes);
      final jsonRes = jsonDecode(decoded);
      if (jsonRes is List) return jsonRes;
      if (jsonRes is Map<String, dynamic> && jsonRes['data'] is List) {
        return List<dynamic>.from(jsonRes['data']);
      }
      throw Exception('Unexpected response shape: expected List.');
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load list from $url [${res.statusCode}]');
    }
  }

  Future<Map<String, dynamic>> postFormDataPrivate(
    String url,
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest('POST', _parseUrl(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });
    if (files != null && files.isNotEmpty) request.files.addAll(files);

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized. Please login again.');
    } else {
      print("API Error POSTFORM [${res.statusCode}]: $body");
      throw Exception('Failed to post form data');
    }
  }

  Future<Map<String, dynamic>> putFormDataPrivate(
    String url,
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest('PUT', _parseUrl(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });
    if (files != null && files.isNotEmpty) request.files.addAll(files);

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized. Please login again.');
    } else {
      print("API Error PUTFORM [${res.statusCode}]: $body");
      throw Exception('Failed to update form data');
    }
  }

  Future<Map<String, dynamic>> deleteWithFormDataPrivate(
    String url,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest('DELETE', _parseUrl(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      return jsonDecode(body);
    } else if (res.statusCode == 401) {
      await prefs.remove('token');
      throw Exception('Unauthorized. Please login again.');
    } else {
      print("API Error DELETE [${res.statusCode}]: $body");
      throw Exception('Failed to delete with form data');
    }
  }
}
