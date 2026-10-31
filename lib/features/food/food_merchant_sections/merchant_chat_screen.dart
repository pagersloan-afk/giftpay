import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchantChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> initialChat;

  const MerchantChatScreen({
    super.key,
    required this.chatId,
    required this.initialChat,
  });

  @override
  State<MerchantChatScreen> createState() => _MerchantChatScreenState();
}

class _MerchantChatScreenState extends State<MerchantChatScreen> {
  static const _bg = Color(0xFF080C14);
  static const _navy = Color(0xFF0F1115);
  static const _cyan = Color(0xFF4FC3F7);
  static const _muted = Color(0xFF9CA8B8);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  DocumentReference<Map<String, dynamic>> get _chatRef =>
      FirebaseFirestore.instance.collection('foodChats').doc(widget.chatId);

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      _chatRef.collection('messages');

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _chatRef.update({
        'unreadForMerchant': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('[GiftPay merchant chat] Mark read failed: $error');
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Messages must be 2,000 characters or fewer.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final merchantUid = '${widget.initialChat['merchantUid'] ?? ''}';
    if (user == null || user.uid != merchantUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in with the authorized merchant account to reply.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final message = _messagesRef.doc();
      batch.set(message, {
        'senderUid': user.uid,
        'senderName': user.displayName ?? user.email ?? 'GiftPay Food',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [user.uid],
        'type': 'text',
      });
      batch.update(_chatRef, {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSenderUid': user.uid,
        'unreadForCustomer': FieldValue.increment(1),
        'unreadForMerchant': 0,
      });
      await batch.commit();
      _controller.clear();
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reply failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(dynamic value) {
    if (value is! Timestamp) return '';
    return TimeOfDay.fromDateTime(value.toDate().toLocal()).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final customerName = '${widget.initialChat['customerName'] ?? 'Customer'}';
    final itemName = '${widget.initialChat['itemName'] ?? 'Food item'}';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customerName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef.orderBy('createdAt', descending: true).limit(300).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Messages could not be loaded. Check Firestore rules.\\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFFC66D)),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _cyan));
                }
                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet.', style: TextStyle(color: _muted)),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final mine = data['senderUid'] == FirebaseAuth.instance.currentUser?.uid;
                    final time = _formatTime(data['createdAt']);
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine ? _cyan.withOpacity(.17) : Colors.white.withOpacity(.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: mine ? _cyan.withOpacity(.35) : Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${data['text'] ?? ''}',
                                  style: const TextStyle(color: Colors.white, height: 1.4)),
                            ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(time, style: const TextStyle(color: _muted, fontSize: 10)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                color: _navy,
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 2000,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Reply to customer…',
                        hintStyle: const TextStyle(color: _muted),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white.withOpacity(.06),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(backgroundColor: _cyan, foregroundColor: _navy),
                    icon: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
