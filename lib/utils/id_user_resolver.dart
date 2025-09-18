import 'package:e_hrm/providers/auth/auth_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> loadUserIdFromPrefs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('id_user');
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
  } catch (_) {
    // Ignore storage errors; caller will handle null.
  }
  return null;
}

Future<String?> resolveUserId(
  AuthProvider auth, {
  BuildContext? context,
}) async {
  final current = auth.currentUser?.idUser;
  if (current != null && current.isNotEmpty) {
    return current;
  }

  if (context != null) {
    await auth.tryRestoreSession(context);
    final restored = auth.currentUser?.idUser;
    if (restored != null && restored.isNotEmpty) {
      return restored;
    }
  }

  return loadUserIdFromPrefs();
}
