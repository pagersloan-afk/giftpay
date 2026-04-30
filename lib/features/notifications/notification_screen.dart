import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'notification_center.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Notifications"),

      body: Column(
        children: [
          // Move "Mark all read" here since AppHeaderr has no actions
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => NotificationCenter.I.markAllRead(),
              child: const Text(
                "Mark all read",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: NotificationCenter.I.notifications,
              builder: (context, List<AppNotification> list, _) {
                if (list.isEmpty) {
                  return const Center(child: Text("No notifications"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = list[index];
                    final time = DateFormat("MMM d, HH:mm").format(n.createdAt);

                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => NotificationCenter.I.delete(n.id),
                      child: ListTile(
                        onTap: () => NotificationCenter.I.markRead(n.id),
                        leading: Icon(
                          n.read
                              ? Icons.notifications_none
                              : Icons.notifications,
                          color: n.read ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.read
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text("$time • ${n.body}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => NotificationCenter.I.delete(n.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
