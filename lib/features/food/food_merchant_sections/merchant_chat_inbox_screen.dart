import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'merchant_chat_screen.dart';
import 'widgets/merchant_chat_tile.dart';

class MerchantChatInboxScreen extends StatelessWidget {
  const MerchantChatInboxScreen({super.key});

  static const _bg = Color(0xFF080C14);
  static const _cyan = Color(0xFF4FC3F7);
  static const _muted = Color(0xFF9CA8B8);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        foregroundColor: Colors.white,
        title: const Text('Customer messages', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view messages.', style: TextStyle(color: _muted)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('foodChats')
                  .where('merchantUid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded, color: Color(0xFFFFC66D), size: 42),
                          const SizedBox(height: 12),
                          const Text('Unable to load customer messages',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text('${snapshot.error}', textAlign: TextAlign.center,
                              style: const TextStyle(color: _muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _cyan));
                }
                final docs = (snapshot.data?.docs ?? []).toList()
                  ..sort((a, b) {
                    final av = a.data()['lastMessageAt'];
                    final bv = b.data()['lastMessageAt'];
                    final at = av is Timestamp ? av.millisecondsSinceEpoch : 0;
                    final bt = bv is Timestamp ? bv.millisecondsSinceEpoch : 0;
                    return bt.compareTo(at);
                  });

                if (docs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 300)),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(28),
                      children: const [
                        SizedBox(height: 100),
                        Icon(Icons.forum_outlined, color: _cyan, size: 54),
                        SizedBox(height: 16),
                        Center(child: Text('No customer conversations yet',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
                        SizedBox(height: 8),
                        Center(child: Text(
                          'When a customer taps Ask on a food item and sends a message, the conversation will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted, height: 1.5),
                        )),
                      ],
                    ),
                  );
                }

                final unread = docs.fold<int>(0, (sum, doc) {
                  final value = doc.data()['unreadForMerchant'];
                  return sum + (value is num ? value.toInt().clamp(0, 999999) : 0);
                });

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Conversations',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: _cyan.withOpacity(.14), borderRadius: BorderRadius.circular(30)),
                            child: Text('$unread unread',
                                style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final doc in docs)
                      MerchantChatTile(
                        chatId: doc.id,
                        chat: doc.data(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MerchantChatScreen(chatId: doc.id, initialChat: doc.data()),
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
