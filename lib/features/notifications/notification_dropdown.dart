import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_center.dart';

Future<void> showNotificationDropdown(BuildContext context) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black26,
    builder: (context) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 70, right: 12),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent, // ⭐ important
            child: Container(
              width: 320,
              constraints: const BoxConstraints(maxHeight: 420),
              padding: const EdgeInsets.symmetric(vertical: 8),

              // ⭐ FIX: match GiftPay dark glass card style
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937), // ⭐ SOLID DARK
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ⭐ HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // ⭐ FIX
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            NotificationCenter.I.markAllRead();
                          },
                          child: const Text(
                            "Mark all read",
                            style: TextStyle(color: Colors.white70), // ⭐ FIX
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Colors.white24),

                  // ⭐ LIST
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: NotificationCenter.I.notifications,
                      builder: (context, List<AppNotification> list, _) {
                        if (list.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "No notifications",
                                style: TextStyle(
                                  color: Colors.white70,
                                ), // ⭐ FIX
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final n = list[index];
                            final time = DateFormat(
                              "MMM d, HH:mm",
                            ).format(n.createdAt);

                            return ListTile(
                              dense: true,
                              onTap: () {
                                NotificationCenter.I.markRead(n.id);
                                Navigator.of(context).pop();
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed("/notifications");
                              },

                              leading: Icon(
                                n.read
                                    ? Icons.notifications_none
                                    : Icons.notifications,
                                color: n.read ? Colors.white38 : Colors.blue,
                              ),

                              title: Text(
                                n.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white, // ⭐ FIX
                                  fontWeight: n.read
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),

                              subtitle: Text(
                                "$time • ${n.body}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70, // ⭐ FIX
                                ),
                              ),

                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white70, // ⭐ FIX
                                ),
                                onPressed: () {
                                  NotificationCenter.I.delete(n.id);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1, color: Colors.white24),

                  // ⭐ VIEW ALL
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/notifications");
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(color: Colors.white70), // ⭐ FIX
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
