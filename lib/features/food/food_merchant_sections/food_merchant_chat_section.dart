part of '../food_merchant_screen.dart';

extension _FoodMerchantChatSection on _FoodMerchantScreenState {
  String _chatTime(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate().toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${dt.hour >= 12 ? 'PM' : 'AM'}';
    }
    if (value is DateTime) {
      final dt = value.toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return '$hour:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    }
    return '';
  }

  Widget _messagesTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _emptyState(
        Icons.lock_outline_rounded,
        'Sign in required',
        'Sign in to view customer messages.',
        'Refresh',
        () => setState(() {}),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('foodChats')
          .where('merchantUid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Temporary diagnostics: distinguish Firestore permission/query failures
        // from a successful query that returns no conversations.
        debugPrint(
          '[GiftPay Food messages] chat stream state=${snapshot.connectionState}, '
          'hasData=${snapshot.hasData}, hasError=${snapshot.hasError}',
        );
        if (snapshot.hasError) {
          debugPrint(
            '[GiftPay Food messages] CHAT STREAM ERROR: ${snapshot.error}',
          );
          debugPrint(
            '[GiftPay Food messages] CHAT STREAM STACK: ${snapshot.stackTrace}',
          );
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 42,
                    color: _FoodMerchantScreenState.cyan,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Messages could not be loaded.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _FoodMerchantScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: _FoodMerchantScreenState.cyan,
            ),
          );
        }

        final chats = snapshot.data?.docs.toList() ?? [];
        debugPrint(
          '[GiftPay Food messages] chat query succeeded; documents=${chats.length}',
        );
        if (chats.isNotEmpty) {
          debugPrint(
            '[GiftPay Food messages] first chat fields=${chats.first.data().keys.toList()}',
          );
        }
        chats.sort((a, b) {
          final av = a.data()['lastMessageAt'];
          final bv = b.data()['lastMessageAt'];
          final at = av is Timestamp ? av.millisecondsSinceEpoch : 0;
          final bt = bv is Timestamp ? bv.millisecondsSinceEpoch : 0;
          return bt.compareTo(at);
        });

        if (chats.isEmpty) {
          return _emptyState(
            Icons.forum_outlined,
            'No customer messages yet',
            'Messages sent from the customer food-item screen will appear here.',
            'Refresh',
            () => setState(() {}),
          );
        }

        final unreadTotal = chats.fold<int>(0, (sum, doc) {
          final value = doc.data()['unreadForMerchant'];
          return sum + (value is num ? value.toInt().clamp(0, 999999) : 0);
        });

        return RefreshIndicator(
          onRefresh: () async {
            // Firestore snapshots update automatically; this gesture is a visual refresh.
            await Future<void>.delayed(const Duration(milliseconds: 250));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Customer conversations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (unreadTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC66D).withOpacity(.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$unreadTotal unread',
                        style: const TextStyle(
                          color: Color(0xFFFFC66D),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              for (final doc in chats)
                _merchantChatTile(context, doc.id, doc.data(), user.uid),
            ],
          ),
        );
      },
    );
  }

  Widget _merchantChatTile(
    BuildContext context,
    String chatId,
    Map<String, dynamic> chat,
    String merchantUid,
  ) {
    final customerUid = '${chat['customerUid'] ?? ''}'.trim();
    if (customerUid.isEmpty) {
      return _merchantChatTileWithProfile(
        context, chatId, chat, merchantUid, const <String, dynamic>{},
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchMerchantCustomerProfile(chatId),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data ?? const <String, dynamic>{};
        return _merchantChatTileWithProfile(context, chatId, chat, merchantUid, profile);
      },
    );
  }

  Future<Map<String, dynamic>> _fetchMerchantCustomerProfile(String chatId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const <String, dynamic>{};
    try {
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return const <String, dynamic>{};
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/food-chat/merchant/conversations/${Uri.encodeComponent(chatId)}/customer');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) return const <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['customer'] is Map) {
        return Map<String, dynamic>.from(decoded['customer'] as Map);
      }
    } catch (error) {
      debugPrint('[GiftPay Food chat] Customer profile lookup failed: $error');
    }
    return const <String, dynamic>{};
  }

  Widget _merchantChatTileWithProfile(
    BuildContext context,
    String chatId,
    Map<String, dynamic> chat,
    String merchantUid,
    Map<String, dynamic> profile,
  ) {
    final firstName = '${profile['firstName'] ?? ''}'.trim();
    final lastName = '${profile['lastName'] ?? ''}'.trim();
    final joinedName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
    final profileName = joinedName.isNotEmpty ? joinedName : '${profile['name'] ?? ''}'.trim();
    final chatName = '${chat['customerName'] ?? ''}'.trim();
    final email = '${profile['email'] ?? chat['customerEmail'] ?? ''}'.trim();
    final customerName = profileName.isNotEmpty
        ? profileName
        : (chatName.isNotEmpty && !chatName.contains('@') ? chatName : (email.isNotEmpty ? email : 'Customer'));
    final avatarUrl = '${profile['profileUrl'] ?? chat['customerProfileUrl'] ?? chat['profileUrl'] ?? ''}'.trim();
    final itemName = '${chat['itemName'] ?? 'Food item'}'.trim();
    final lastMessage = '${chat['lastMessage'] ?? 'Start a conversation'}'.trim();
    final unreadValue = chat['unreadForMerchant'];
    final unread = unreadValue is num ? unreadValue.toInt().clamp(0, 999999) : 0;
    final time = _chatTime(chat['lastMessageAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.065),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _FoodMerchantScreenState.line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => _FoodMerchantConversationScreen(
              chatId: chatId,
              merchantUid: merchantUid,
              initialChat: {...chat, 'customerName': customerName, 'customerProfileUrl': avatarUrl},
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _FoodMerchantScreenState.blue.withOpacity(.35),
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  onBackgroundImageError: avatarUrl.isNotEmpty ? (_, __) {} : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person_outline_rounded, color: _FoodMerchantScreenState.cyan)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Expanded(child: Text(
                          customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        )),
                        if (time.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(time, maxLines: 1, style: const TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 10)),
                        ],
                      ]),
                      const SizedBox(height: 5),
                      Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _FoodMerchantScreenState.cyan, fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(lastMessage.isEmpty ? 'Start a conversation' : lastMessage,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (unread > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: _FoodMerchantScreenState.cyan, shape: BoxShape.circle),
                    child: Text(unread > 999 ? '999+' : '$unread',
                      style: const TextStyle(color: _FoodMerchantScreenState.navy, fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Conversation options',
                  icon: const Icon(Icons.more_vert_rounded, color: _FoodMerchantScreenState.muted),
                  onSelected: (value) {
                    if (value == 'delete') _confirmDeleteMerchantChat(context, chatId, customerName);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(value: 'delete', child: Row(children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      SizedBox(width: 10), Text('Delete conversation'),
                    ])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMerchantChat(BuildContext context, String chatId, String customerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('This permanently deletes the conversation with $customerName, including its messages. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) throw Exception('Please sign in again.');
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/food-chat/merchant/conversations/${Uri.encodeComponent(chatId)}');
      final response = await http.delete(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'Could not delete this conversation.';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) message = decoded['message'] as String;
        } catch (_) {}
        throw Exception(message);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conversation deleted.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${error.toString().replaceFirst('Exception: ', '')}')));
      }
    }
  }

}

class _FoodMerchantConversationScreen extends StatefulWidget {
  final String chatId;
  final String merchantUid;
  final Map<String, dynamic> initialChat;

  const _FoodMerchantConversationScreen({
    required this.chatId,
    required this.merchantUid,
    required this.initialChat,
  });

  @override
  State<_FoodMerchantConversationScreen> createState() =>
      _FoodMerchantConversationScreenState();
}

class _FoodMerchantConversationScreenState
    extends State<_FoodMerchantConversationScreen> {
  static const _navy = Color(0xFF0F1115);
  static const _cyan = Color(0xFF4FC3F7);
  static const _muted = Color(0xFF9CA8B8);
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  bool _markingRead = false;

  DocumentReference<Map<String, dynamic>> get _chatRef =>
      FirebaseFirestore.instance.collection('foodChats').doc(widget.chatId);

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      _chatRef.collection('messages');

  @override
  void initState() {
    super.initState();
    _markConversationRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _markConversationRead() async {
    if (_markingRead) return;
    _markingRead = true;
    try {
      await _chatRef.update({
        'unreadForMerchant': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[GiftPay Food chat] Could not mark conversation read: $e');
    } finally {
      _markingRead = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages must be 2,000 characters or fewer.'),
        ),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.merchantUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The authorized merchant account is required to reply.',
          ),
        ),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final messageRef = _messagesRef.doc();
      batch.set(messageRef, {
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
      if (_scroll.hasClients) {
        await _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reply failed: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _time(dynamic value) {
    if (value is! Timestamp) return '';
    final dt = value.toDate().toLocal();
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    return '$h:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> _reactToMessage(String messageId, String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.merchantUid) return;
    final ref = _messagesRef.doc(messageId);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snap = await transaction.get(ref);
        if (!snap.exists) return;
        final data = snap.data() ?? <String, dynamic>{};
        final raw = data['reactions'];
        final reactions = <String, dynamic>{};
        if (raw is Map) raw.forEach((key, value) { reactions['$key'] = value; });
        final users = <String>[];
        final current = reactions[emoji];
        if (current is List) users.addAll(current.whereType<String>());
        if (users.contains(user.uid)) {
          users.remove(user.uid);
        } else {
          users.add(user.uid);
        }
        if (users.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = users;
        }
        transaction.update(ref, {'reactions': reactions});
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reaction failed: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  Future<void> _showReactionPicker(String messageId) async {
    const emojis = ['❤️', '😂', '👍', '😮', '😢', '🙏', '🔥', '🎉'];
    final emoji = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _navy,
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: emojis.map((emoji) => InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(sheetContext, emoji),
            child: Padding(padding: const EdgeInsets.all(8), child: Text(emoji, style: const TextStyle(fontSize: 30))),
          )).toList(),
        ),
      )),
    );
    if (emoji != null) await _reactToMessage(messageId, emoji);
  }

  Widget _reactionChips(String messageId, Map<String, dynamic> data) {
    final raw = data['reactions'];
    if (raw is! Map || raw.isEmpty) return const SizedBox.shrink();
    final entries = raw.entries.where((entry) => entry.value is List && (entry.value as List).isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 5, runSpacing: 4,
      children: entries.map((entry) {
        final users = (entry.value as List).whereType<String>().toList();
        final mine = users.contains(FirebaseAuth.instance.currentUser?.uid);
        return InkWell(onTap: () => _reactToMessage(messageId, '${entry.key}'),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: mine ? _cyan.withOpacity(.22) : Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(20), border: Border.all(color: mine ? _cyan : Colors.white24)),
            child: Text('${entry.key} ${users.length}', style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        );
      }).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final customer = '${widget.initialChat['customerName'] ?? 'Customer'}';
    final itemName = '${widget.initialChat['itemName'] ?? 'Food item'}';
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back to conversations',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: _cyan.withOpacity(.2),
              backgroundImage: ('${widget.initialChat['customerProfileUrl'] ?? ''}'.trim().isNotEmpty)
                  ? NetworkImage('${widget.initialChat['customerProfileUrl']}')
                  : null,
              child: ('${widget.initialChat['customerProfileUrl'] ?? ''}'.trim().isEmpty)
                  ? const Icon(Icons.person_outline_rounded, color: _cyan, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            )),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                debugPrint(
                  '[GiftPay Food conversation] stream state=${snapshot.connectionState}, '
                  'hasData=${snapshot.hasData}, hasError=${snapshot.hasError}',
                );
                if (snapshot.hasError) {
                  debugPrint(
                    '[GiftPay Food conversation] MESSAGE STREAM ERROR: ${snapshot.error}',
                  );
                  debugPrint(
                    '[GiftPay Food conversation] MESSAGE STREAM STACK: ${snapshot.stackTrace}',
                  );
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load messages: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _cyan),
                  );
                }
                final messages = snapshot.data?.docs ?? [];
                debugPrint(
                  '[GiftPay Food conversation] message query succeeded; documents=${messages.length}',
                );
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Send a reply below.',
                      style: TextStyle(color: _muted),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final mine = data['senderUid'] == widget.merchantUid;
                    final text = '${data['text'] ?? ''}';
                    final time = _time(data['createdAt']);
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .78,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? _cyan.withOpacity(.18)
                              : Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: mine
                                ? _cyan.withOpacity(.4)
                                : Colors.white12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(time, style: const TextStyle(color: _muted, fontSize: 10)),
                            ],
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 30, minHeight: 28),
                                padding: EdgeInsets.zero,
                                tooltip: 'React to message',
                                onPressed: () => _showReactionPicker(messages[index].id),
                                icon: const Icon(Icons.add_reaction_outlined, size: 17, color: _muted),
                              ),
                            ]),
                            _reactionChips(messages[index].id, data),
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
              decoration: BoxDecoration(
                color: _navy,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(.1)),
                ),
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
                        hintText: 'Write a reply…',
                        hintStyle: const TextStyle(color: _muted),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white.withOpacity(.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: _cyan,
                      foregroundColor: _navy,
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    tooltip: 'Send reply',
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
