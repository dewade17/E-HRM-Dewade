// lib/providers/notifications/notifications_provider.dart

import 'dart:async';
import 'package:e_hrm/contraints/endpoints.dart';
import 'package:e_hrm/dto/notification/notification.dart';

import 'package:e_hrm/services/api_services.dart';
import 'package:flutter/foundation.dart';

enum NotificationFilter { semua, belumDibaca, telahDibaca }

class NotificationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<NotificationItem> _items = [];
  Pagination? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  NotificationFilter _filter = NotificationFilter.semua;
  final Set<String> _pendingRead = <String>{};

  List<NotificationItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  NotificationFilter get filter => _filter;
  bool get canLoadMore =>
      _pagination != null && _pagination!.page < _pagination!.totalPages;

  // ... (method fetchNotifications, setFilter, refresh tidak berubah)
  Future<void> fetchNotifications({bool append = false}) async {
    if (_isLoading || (append && _isLoadingMore)) return;

    if (append) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    try {
      final page = append ? (_pagination?.page ?? 0) + 1 : 1;
      final params = <String, String>{
        'page': page.toString(),
        'pageSize': '20',
      };
      switch (_filter) {
        case NotificationFilter.belumDibaca:
          params['status'] = 'unread';
          break;
        case NotificationFilter.telahDibaca:
          params['status'] = 'read';
          break;
        case NotificationFilter.semua:
          break;
      }
      final uri = Uri.parse(
        '${Endpoints.baseURL}/notifications',
      ).replace(queryParameters: params);

      final response = await _api.fetchDataPrivate(uri.toString());
      final result = NotificationHistoryList.fromJson(response);

      if (append) {
        _items.addAll(result.data);
      } else {
        _items = result.data;
      }
      _pagination = result.pagination;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_pendingRead.contains(notificationId)) return;

    final index = _items.indexWhere((item) => item.id == notificationId);
    if (index == -1 || _items[index].status == 'read') {
      return;
    }

    _pendingRead.add(notificationId);
    final originalItem = _items[index];
    _items[index] = NotificationItem(
      id: originalItem.id,
      title: originalItem.title,
      body: originalItem.body,
      status: 'read',
      createdAt: originalItem.createdAt,
    );
    notifyListeners();

    try {
      final url = '${Endpoints.baseURL}/notifications/$notificationId';
      // --- PERUBAHAN DI SINI ---
      // Menggunakan updateDataPrivate (PUT) sesuai dengan endpoint baru
      await _api.updateDataPrivate(url, {'status': 'read'});
    } catch (e) {
      _items[index] = originalItem;
      notifyListeners();
      debugPrint("Failed to mark notification as read: $e");
    } finally {
      _pendingRead.remove(notificationId);
    }
  }

  Future<void> setFilter(NotificationFilter newFilter) async {
    if (_filter == newFilter) return;
    _filter = newFilter;
    await fetchNotifications();
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }
}
