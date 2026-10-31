import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Customer inbox for restaurant conversations. Uses foodChats/{chatId}/messages,
/// matching the merchant chat's Firestore contract.
class FoodCustomerMessagesScreen extends StatelessWidget {
  const FoodCustomerMessagesScreen({super.key});

  static const _bg = Color(0xFF080C14);
  static const _surface = Color(0xFF111B2A);
  static const _cyan = Color(0xFF4FC3F7);
  static const _muted = Color(0xFF9CA8B8);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Restaurant messages', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your messages.', style: TextStyle(color: _muted)))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('foodChats').where('customerUid', isEqualTo: user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Unable to load messages. Check your connection and Firestore permissions.', textAlign: TextAlign.center, style: TextStyle(color: _muted)),
                      ));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _cyan));
                    }
                    final chats = (snapshot.data?.docs ?? []).toList()
                      ..sort((a, b) => _millis(b.data()['lastMessageAt']).compareTo(_millis(a.data()['lastMessageAt'])));
                    if (chats.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(28),
                        children: const [
                          SizedBox(height: 75),
                          Icon(Icons.forum_outlined, size: 58, color: _cyan),
                          SizedBox(height: 16),
                          Center(child: Text('Your restaurant chats will appear here', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                          SizedBox(height: 8),
                          Center(child: Text('Open a food item and tap Ask to start a conversation with its restaurant.', textAlign: TextAlign.center, style: TextStyle(color: _muted, height: 1.5))),
                        ],
                      );
                    }
                    final unread = chats.fold<int>(0, (sum, d) {
                      final n = d.data()['unreadForCustomer'];
                      return sum + (n is num ? n.toInt().clamp(0, 999999) : 0);
                    });
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      children: [
                        Row(children: [
                          const Expanded(child: Text('Your conversations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                          if (unread > 0) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: _cyan.withOpacity(.14), borderRadius: BorderRadius.circular(30)),
                            child: Text('$unread unread', style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.w900)),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        for (final doc in chats) _conversationTile(context, doc.id, doc.data()),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  static int _millis(dynamic value) => value is Timestamp ? value.millisecondsSinceEpoch : 0;

  static String restaurantNameFromData(Map<String, dynamic> data) {
    for (final key in ['restaurantName', 'merchantName', 'merchantName', 'businessName', 'storeName']) {
      final value = '${data[key] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return 'GiftPay Food restaurant';
  }

  static String _time(dynamic value) {
    if (value is! Timestamp) return '';
    final d = value.toDate().toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _conversationTile(BuildContext context, String id, Map<String, dynamic> data) {
    final name = restaurantNameFromData(data);
    final item = '${data['itemName'] ?? ''}'.trim();
    final preview = '${data['lastMessage'] ?? 'Tap to view conversation'}'.trim();
    final logo = '${data['merchantLogoUrl'] ?? data['logoUrl'] ?? ''}'.trim();
    final unreadValue = data['unreadForCustomer'];
    final unread = unreadValue is num ? unreadValue.toInt().clamp(0, 999999) : 0;
    final time = _time(data['lastMessageAt']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x244FC3F7)),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => FoodItemChatScreen(
          item: <String, dynamic>{
            'id': data['itemId'] ?? id.split('_').skip(1).join('_'),
            'itemId': data['itemId'] ?? id.split('_').skip(1).join('_'),
            'name': data['itemName'] ?? 'Food item',
            'price': data['itemPrice'] ?? 0,
            'imageUrl': data['itemImageUrl'] ?? '',
          },
          merchantUid: '${data['merchantUid'] ?? ''}',
          merchantName: restaurantNameFromData(data),
          merchantLogoUrl: '${data['merchantLogoUrl'] ?? data['logoUrl'] ?? ''}',
        ))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: const Color(0xFF19324A),
          backgroundImage: logo.startsWith('http') ? NetworkImage(logo) : null,
          child: logo.startsWith('http') ? null : const Icon(Icons.storefront_rounded, color: _cyan),
        ),
        title: Row(children: [
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          if (time.isNotEmpty) Text(time, style: const TextStyle(color: _muted, fontSize: 10)),
        ]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (item.isNotEmpty) Text(item, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _cyan, fontSize: 11, fontWeight: FontWeight.w800)),
            if (item.isNotEmpty) const SizedBox(height: 4),
            Text(preview.isEmpty ? 'No messages yet' : preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, height: 1.35)),
          ]),
        ),
        trailing: unread > 0
            ? Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: const BoxDecoration(color: _cyan, shape: BoxShape.circle), child: Text(unread > 99 ? '99+' : '$unread', style: const TextStyle(color: Color(0xFF08111C), fontWeight: FontWeight.w900, fontSize: 11)))
            : const Icon(Icons.chevron_right_rounded, color: _muted),
      ),
    );
  }
}

/// Item-specific customer chat. Reactions use the same reactions: {emoji: [uid]}
/// format used by the merchant chat implementation.
class FoodItemChatScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String merchantUid;
  final String merchantName;
  final String merchantLogoUrl;

  const FoodItemChatScreen({super.key, required this.item, required this.merchantUid, required this.merchantName, this.merchantLogoUrl = ''});

  @override
  State<FoodItemChatScreen> createState() => _FoodItemChatScreenState();
}

class _FoodItemChatScreenState extends State<FoodItemChatScreen> {
  static const _bg = Color(0xFF080C14);
  static const _surface = Color(0xFF111B2A);
  static const _cyan = Color(0xFF4FC3F7);
  static const _muted = Color(0xFF9CA8B8);
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _initializing = true;
  String? _initError;

  User? get _user => FirebaseAuth.instance.currentUser;
  String get _itemId {
    final raw = '${widget.item['id'] ?? widget.item['itemId'] ?? widget.item['name'] ?? 'food'}';
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }
  String get _conversationId => '${_user!.uid}_$_itemId';
  DocumentReference<Map<String, dynamic>> get _conversationRef => FirebaseFirestore.instance.collection('foodChats').doc(_conversationId);
  CollectionReference<Map<String, dynamic>> get _messagesRef => _conversationRef.collection('messages');

  @override
  void initState() {
    super.initState();
    _ensureConversation().then((_) {
      if (mounted) setState(() => _initializing = false);
    }).catchError((Object e) {
      if (mounted) setState(() {
        _initError = e.toString().replaceFirst('Exception: ', '');
        _initializing = false;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureConversation() async {
    final user = _user;
    if (user == null) throw Exception('Please sign in to message the restaurant.');
    if (widget.merchantUid.trim().isEmpty) throw Exception('Restaurant chat is not configured.');
    final ref = FirebaseFirestore.instance.collection('foodChats').doc('${user.uid}_$_itemId');
    final snap = await ref.get();
    if (snap.exists) {
      final existing = snap.data() ?? <String, dynamic>{};
      if (existing['customerUid'] != user.uid) throw Exception('This conversation is not available to your account.');
      // Keep metadata current without overwriting messages or unread counters.
      await ref.set({'merchantName': widget.merchantName, 'merchantLogoUrl': widget.merchantLogoUrl, 'restaurantName': widget.merchantName, 'itemName': '${widget.item['name'] ?? 'Food item'}', 'itemImageUrl': '${widget.item['imageUrl'] ?? ''}'}, SetOptions(merge: true));
      return;
    }
    await ref.set({
      'customerUid': user.uid,
      'customerName': user.displayName ?? user.email ?? 'Customer',
      'merchantUid': widget.merchantUid,
      'merchantName': widget.merchantName,
      'restaurantName': widget.merchantName,
      'merchantLogoUrl': widget.merchantLogoUrl,
      'itemId': _itemId,
      'itemName': '${widget.item['name'] ?? 'Food item'}',
      'itemPrice': widget.item['price'] ?? 0,
      'itemImageUrl': '${widget.item['imageUrl'] ?? ''}',
      'participants': [user.uid, widget.merchantUid],
      'lastMessage': '',
      'unreadForCustomer': 0,
      'unreadForMerchant': 0,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _sendMessage() async {
    final user = _user;
    final text = _messageController.text.trim();
    if (user == null || text.isEmpty || _sending) return;
    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages must be 2,000 characters or fewer.')));
      return;
    }
    setState(() => _sending = true);
    try {
      await _ensureConversation();
      final batch = FirebaseFirestore.instance.batch();
      final messageRef = _messagesRef.doc();
      batch.set(messageRef, {'senderUid': user.uid, 'senderName': user.displayName ?? user.email ?? 'Customer', 'text': text, 'createdAt': FieldValue.serverTimestamp(), 'readBy': [user.uid], 'type': 'text'});
      batch.update(_conversationRef, {'lastMessage': text, 'lastMessageAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(), 'lastSenderUid': user.uid, 'unreadForMerchant': FieldValue.increment(1), 'unreadForCustomer': 0});
      await batch.commit();
      _messageController.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message not sent: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _react(String messageId, String emoji) async {
    final user = _user;
    if (user == null) return;
    final ref = _messagesRef.doc(messageId);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) return;
        final raw = snap.data()?['reactions'];
        final reactions = <String, dynamic>{};
        if (raw is Map) raw.forEach((k, v) => reactions['$k'] = v);
        final users = <String>[];
        final current = reactions[emoji];
        if (current is List) users.addAll(current.whereType<String>());
        if (users.contains(user.uid)) { users.remove(user.uid); } else { users.add(user.uid); }
        if (users.isEmpty) { reactions.remove(emoji); } else { reactions[emoji] = users; }
        tx.update(ref, {'reactions': reactions});
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reaction failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  Future<void> _showReactionPicker(String messageId) async {
    const emojis = ['❤️', '😂', '👍', '😮', '😢', '🙏', '🔥', '🎉'];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          for (final emoji in emojis) InkWell(
            onTap: () { Navigator.pop(ctx); _react(messageId, emoji); },
            borderRadius: BorderRadius.circular(14),
            child: Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(14)), child: Text(emoji, style: const TextStyle(fontSize: 25))),
          ),
        ]),
      )),
    );
  }

  Widget _reactionChips(String messageId, Map<String, dynamic> data) {
    final raw = data['reactions'];
    if (raw is! Map || raw.isEmpty) return const SizedBox.shrink();
    final uid = _user?.uid;
    final chips = <Widget>[];
    raw.forEach((key, value) {
      final users = value is List ? value.whereType<String>().toList() : <String>[];
      if (users.isEmpty) return;
      final selected = uid != null && users.contains(uid);
      chips.add(InkWell(
        onTap: () => _react(messageId, '$key'),
        borderRadius: BorderRadius.circular(20),
        child: Container(margin: const EdgeInsets.only(right: 5, top: 5), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: selected ? _cyan.withOpacity(.2) : Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? _cyan : Colors.white12)), child: Text('$key ${users.length}', style: const TextStyle(color: Colors.white, fontSize: 12))),
      ));
    });
    return Wrap(children: chips);
  }

  String _time(dynamic value) {
    if (value is! Timestamp) return 'Sending…';
    final d = value.toDate().toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final itemName = '${widget.item['name'] ?? 'Food item'}';
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: const Color(0xFF19324A), backgroundImage: widget.merchantLogoUrl.startsWith('http') ? NetworkImage(widget.merchantLogoUrl) : null, child: widget.merchantLogoUrl.startsWith('http') ? null : const Icon(Icons.storefront_rounded, color: _cyan, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.merchantName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _cyan)),
          ])),
        ]),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in again.', style: TextStyle(color: _muted)))
          : Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820), child: Column(children: [
              Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(14, 8, 14, 0), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0x244FC3F7))), child: Row(children: [
                const Icon(Icons.restaurant_menu_rounded, color: _cyan), const SizedBox(width: 10), Expanded(child: Text('Question about $itemName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
              ])),
              if (_initError != null) Padding(padding: const EdgeInsets.all(10), child: Text(_initError!, style: const TextStyle(color: Color(0xFFFFC66D)))),
              Expanded(child: _initializing
                  ? const Center(child: CircularProgressIndicator(color: _cyan))
                  : _initError != null
                      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_initError!, textAlign: TextAlign.center, style: const TextStyle(color: _muted))))
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _messagesRef.orderBy('createdAt').limit(500).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Unable to load this chat. Check your Firestore rules and connection.', textAlign: TextAlign.center, style: TextStyle(color: _muted))));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _cyan));
                  final docs = snapshot.data!.docs;
                  WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent); });
                  if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(28), child: Text('Ask your question below. The restaurant can reply here.', textAlign: TextAlign.center, style: TextStyle(color: _muted, height: 1.5))));
                  return ListView.builder(controller: _scrollController, padding: const EdgeInsets.fromLTRB(14, 16, 14, 18), itemCount: docs.length, itemBuilder: (context, index) {
                    final doc = docs[index]; final data = doc.data(); final mine = data['senderUid'] == user.uid;
                    return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width < 600 ? MediaQuery.sizeOf(context).width * .82 : 540), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.fromLTRB(13, 10, 10, 7), decoration: BoxDecoration(color: mine ? const Color(0xFF164E78) : _surface, borderRadius: BorderRadius.only(topLeft: const Radius.circular(17), topRight: const Radius.circular(17), bottomLeft: Radius.circular(mine ? 17 : 4), bottomRight: Radius.circular(mine ? 4 : 17)), border: Border.all(color: mine ? const Color(0x334FC3F7) : Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${data['text'] ?? ''}', style: const TextStyle(color: Colors.white, height: 1.4)), const SizedBox(height: 4), Row(mainAxisSize: MainAxisSize.min, children: [Text(_time(data['createdAt']), style: const TextStyle(color: Colors.white60, fontSize: 10)), const SizedBox(width: 6), IconButton(visualDensity: VisualDensity.compact, constraints: const BoxConstraints(minWidth: 30, minHeight: 28), padding: EdgeInsets.zero, tooltip: 'React to message', onPressed: () => _showReactionPicker(doc.id), icon: const Icon(Icons.add_reaction_outlined, size: 17, color: Colors.white70))]), _reactionChips(doc.id, data),
                    ]))));
                  });
                },
              )),
              SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), decoration: const BoxDecoration(color: Color(0xFF0F1115), border: Border(top: BorderSide(color: Color(0x244FC3F7)))), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: TextField(controller: _messageController, minLines: 1, maxLines: 5, maxLength: 2000, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Ask a question about this food…', hintStyle: const TextStyle(color: _muted), filled: true, fillColor: const Color(0xFF182333), counterText: '', contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)), onSubmitted: (_) => _sendMessage())),
                const SizedBox(width: 8), IconButton.filled(onPressed: _sending ? null : _sendMessage, icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded), style: IconButton.styleFrom(backgroundColor: _cyan, foregroundColor: const Color(0xFF07111B))),
              ]))),
            ]))),
    );
  }
}
