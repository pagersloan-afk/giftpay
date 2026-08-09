import 'package:flutter/material.dart';
import 'package:utilityhub/features/notifications/notification_center.dart';
import 'package:utilityhub/features/notifications/notification_dropdown.dart';

class HeaderNotifications extends StatelessWidget {
  const HeaderNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await showNotificationDropdown(context),
      child: ValueListenableBuilder(
        valueListenable: NotificationCenter.I.notifications,
        builder: (context, list, _) {
          final hasUnread = list.any((n) => !n.read);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 28,
              ),
              if (hasUnread)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
