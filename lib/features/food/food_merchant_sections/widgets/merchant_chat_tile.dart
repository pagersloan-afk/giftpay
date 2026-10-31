import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MerchantChatTile extends StatelessWidget {
  final String chatId;
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const MerchantChatTile({
    super.key,
    required this.chatId,
    required this.chat,
    required this.onTap,
  });

  String _time(dynamic value) {
    if (value is! Timestamp) return '';
    final date = value.toDate().toLocal();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    return '$hour:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final customer = '${chat['customerName'] ?? 'Customer'}'.trim();
    final item = '${chat['itemName'] ?? 'Food item'}'.trim();
    final preview = '${chat['lastMessage'] ?? ''}'.trim();
    final unreadValue = chat['unreadForMerchant'];
    final unread = unreadValue is num ? unreadValue.toInt().clamp(0, 999999) : 0;
    final time = _time(chat['lastMessageAt']);

    return Card(
      color: const Color(0xFF111B2A),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x244FC3F7)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0A4D9C),
          child: const Icon(Icons.person_outline_rounded, color: Color(0xFF4FC3F7)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.isEmpty ? 'Customer' : customer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            if (time.isNotEmpty)
              Text(time, style: const TextStyle(color: Color(0xFF9CA8B8), fontSize: 10)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                preview.isEmpty ? 'No messages yet' : preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF9CA8B8), fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: unread > 0
            ? Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(color: Color(0xFF4FC3F7), shape: BoxShape.circle),
                child: Text('$unread', style: const TextStyle(color: Color(0xFF07111B), fontWeight: FontWeight.w900, fontSize: 11)),
              )
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA8B8)),
      ),
    );
  }
}
