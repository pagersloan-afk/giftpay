import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
    );
  }
}

class NotificationCenter {
  NotificationCenter._internal();
  static final NotificationCenter _instance = NotificationCenter._internal();
  static NotificationCenter get I => _instance;

  final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>([]);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  String? _currentUserId;

  /// Call this whenever the authenticated user changes.
  /// Idempotent and hot‑reload safe.
  void setUser(String userId) {
    if (_currentUserId == userId && _sub != null) return;

    _currentUserId = userId;
    _startListener(userId);
  }

  void _startListener(String userId) {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50) // scalable: only latest 50 in memory
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => AppNotification.fromDoc(doc))
                .toList(growable: false);

            notifications.value = list;
          },
          onError: (e) {
            // In production you may route this to a logger (Sentry, etc.)
          },
        );
  }

  bool get hasUser => _currentUserId != null;

  String? get currentUserId => _currentUserId;

  int get unreadCount => notifications.value.where((n) => !n.read).length;

  Future<void> markRead(String id) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final list = List<AppNotification>.from(notifications.value);
    final index = list.indexWhere((n) => n.id == id);
    if (index == -1) return;

    list[index].read = true;
    notifications.value = list;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .update({'read': true});
  }

  Future<void> delete(String id) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final list = notifications.value
        .where((n) => n.id != id)
        .toList(growable: false);
    notifications.value = list;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .delete();
  }

  Future<void> markAllRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final list = List<AppNotification>.from(notifications.value);
    if (list.isEmpty) return;

    for (var n in list) {
      n.read = true;
    }
    notifications.value = list;

    final batch = FirebaseFirestore.instance.batch();
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications');

    for (var n in list) {
      batch.update(ref.doc(n.id), {'read': true});
    }

    await batch.commit();
  }

  /// Call on logout.
  void dispose() {
    _sub?.cancel();
    _sub = null;
    _currentUserId = null;
    notifications.value = const [];
  }
}
