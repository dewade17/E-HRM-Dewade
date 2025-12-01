// ignore_for_file: deprecated_member_use

import 'package:e_hrm/dto/notification/notification.dart' as history_dto;
import 'package:e_hrm/providers/notifications/notifications_provider.dart';
import 'package:e_hrm/utils/mention_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:e_hrm/contraints/colors.dart';

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().fetchNotifications(append: true);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _handleMarkAllAsRead() async {
    final provider = context.read<NotificationProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final hasUnread = provider.items.any((n) => n.status != 'read');
    if (!hasUnread && !provider.isLoading) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Semua notifikasi sudah dibaca.')),
      );
      return;
    }

    await provider.markAllAsRead();

    if (!mounted) return;

    if (provider.error == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi telah ditandai dibaca.'),
          backgroundColor: AppColors.succesColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final hasUnread = provider.items.any((n) => n.status != 'read');
        final isBusy = provider.isLoading || provider.isLoadingMore;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: (hasUnread && !isBusy)
                        ? _handleMarkAllAsRead
                        : null,
                    icon: Icon(
                      Icons.done_all,
                      size: 20,
                      color: (hasUnread && !isBusy)
                          ? AppColors.primaryColor
                          : Colors.grey,
                    ),
                    label: Text(
                      'Baca Semua',
                      style: TextStyle(
                        color: (hasUnread && !isBusy)
                            ? AppColors.primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 160,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<NotificationFilter>(
                          value: provider.filter,
                          underline: const SizedBox.shrink(),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: isBusy
                              ? null
                              : (val) {
                                  if (val != null) {
                                    provider.setFilter(val);
                                  }
                                },
                          items: NotificationFilter.values
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(
                                    _capitalize(
                                      f.name.replaceAll('Dibaca', ' Dibaca'),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: _buildBody(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.items.isEmpty) {
      return Center(child: Text('Gagal memuat: ${provider.error}'));
    }
    if (provider.items.isEmpty) {
      return const Center(child: Text('Tidak ada notifikasi.'));
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: provider.items.length + (provider.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= provider.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final n = provider.items[index];
        return GestureDetector(
          onTap: () {
            if (n.status != 'read') {
              context.read<NotificationProvider>().markAsRead(n.id);
            }
          },
          child: _NotificationCard(notif: n),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notif});

  final history_dto.NotificationItem notif;

  static const _bgUnread = Color(0xFFEAF8F3);
  static const _bgRead = Color(0xFFF6FAF8);
  static const _accent = Color(0xFF18A36C);

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd-MM-yyyy, HH:mm', 'id_ID').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notif.status.toLowerCase() != 'unread';
    final bg = isRead ? _bgRead : _bgUnread;

    final displayBody = MentionParser.convertMarkupToDisplay(notif.body);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead ? const Color(0xFFE5E7EB) : _accent.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _accent.withOpacity(.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications,
                  size: 20,
                  color: _accent,
                ),
              ),
              if (!isRead)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayBody,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDateTime(notif.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B).withOpacity(.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
