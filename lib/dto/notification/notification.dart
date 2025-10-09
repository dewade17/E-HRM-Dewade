import 'dart:convert';

NotificationHistoryList notificationHistoryListFromJson(String str) =>
    NotificationHistoryList.fromJson(json.decode(str));

class NotificationHistoryList {
  final List<NotificationItem> data;
  final Pagination? pagination;

  NotificationHistoryList({required this.data, this.pagination});

  factory NotificationHistoryList.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryList(
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) =>
                    NotificationItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id_notification'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? 'No Title').toString(),
      body: (json['body'] ?? '').toString(),
      status: (json['status'] ?? 'unread').toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
