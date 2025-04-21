import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/provider/notification_provider.dart';
import '../data/models/notification_model.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_as_unread),
              onPressed: provider.markAllAsRead,
              tooltip: 'Marquer tout comme lu',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNotificationList(provider.notifications),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text('Aucune notification disponible'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationProvider>().loadNotifications(),
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? null : Colors.blue[50],
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          '${notification.date.hour}:${notification.date.minute.toString().padLeft(2, '0')}',
        ),
        onTap: () {
          context.read<NotificationProvider>().markAsRead(notification.id);
          // Naviguer vers la route spécifiée si elle existe
          if (notification.route != null) {
            Navigator.pushNamed(
              context,
              notification.route!,
              arguments: notification.payload,
            );
          }
        },
      ),
    );
  }
}