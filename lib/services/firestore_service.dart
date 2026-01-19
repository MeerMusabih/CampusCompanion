import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mad_project/models/lost_found_model.dart';
import 'package:mad_project/models/timetable_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notice_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/forum_post_model.dart';
import '../models/chat_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../core/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Stream<List<TimetableModel>> getTimetable() {
    return _db
        .collection('timetable')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTimetableEntry(TimetableModel entry) async {
    await _db.collection('timetable').add(entry.toMap());
  }

  Future<void> deleteTimetableEntry(String id) async {
    await _db.collection('timetable').doc(id).delete();
  }

  Future<void> uploadLostFoundItem(
    LostFoundModel item,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final String path = 'items/$fileName';
      await _supabase.storage.from('images').uploadBinary(path, imageBytes);
      final String imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(path);

      await _supabase.from('lost_items').insert({
        'title': item.title,
        'description': item.description,
        'location': item.location,
        'type': item.type,
        'image_url': imageUrl,
        'contact_info': item.contactInfo,
        'user_id': item.postedBy,
        'is_resolved': false,
        'kept_at': item.keptAt,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw "Supabase Error: $e";
    }
  }

  Stream<List<LostFoundModel>> getLostFoundItems() {
    return _supabase
        .from('lost_items')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((map) => LostFoundModel.fromMap(map)).toList());
  }

  Future<void> updateItemStatus(String itemId, bool status) async {
    await _supabase
        .from('lost_items')
        .update({'is_resolved': status})
        .eq('id', itemId);
  }

  Future<int> getUserLostFoundCount(String userId) async {
    try {
      final List response = await _supabase
          .from('lost_items')
          .select('id')
          .eq('user_id', userId);
      return response.length;
    } catch (e) {
      debugPrint("Error fetching lost/found count: $e");
      return 0;
    }
  }

  Future<int> getUserForumPostsCount(String userId) async {
    try {
      final snapshot = await _db
          .collection('forums')
          .where('authorId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint("Error fetching forum posts count: $e");
      return 0;
    }
  }

  Stream<List<ForumPostModel>> getUserForumPosts(String userId) {
    return _db
        .collection('forums')
        .where('authorId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ForumPostModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<NoticeModel>> getUserNotices(String userId) {
    return _db
        .collection(AppConstants.noticesCollection)
        .where('authorId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<NoticeModel>> getNotices() {
    return _db
        .collection(AppConstants.noticesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<QuerySnapshot> getNoticesOnce() async {
    return await _db
        .collection(AppConstants.noticesCollection)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<UserModel> getUser(String uid) async {
    var doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> addNotice(NoticeModel notice) async {
    await _db.collection(AppConstants.noticesCollection).add(notice.toMap());
  }

  Future<void> deleteNotice(String id) async {
    await _db.collection(AppConstants.noticesCollection).doc(id).delete();
  }

  Future<void> toggleLikeNotice(String noticeId, String userId) async {
    final docRef = _db.collection(AppConstants.noticesCollection).doc(noticeId);
    final doc = await docRef.get();
    if (doc.exists) {
      final List<String> likes = List<String>.from(doc.data()?['likes'] ?? []);
      if (likes.contains(userId)) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  Future<void> toggleBookmarkNotice(String noticeId, String userId) async {
    final docRef = _db.collection(AppConstants.noticesCollection).doc(noticeId);
    final doc = await docRef.get();
    if (doc.exists) {
      final List<String> bookmarks = List<String>.from(
        doc.data()?['bookmarks'] ?? [],
      );
      if (bookmarks.contains(userId)) {
        await docRef.update({
          'bookmarks': FieldValue.arrayRemove([userId]),
        });
      } else {
        await docRef.update({
          'bookmarks': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  Stream<List<EventModel>> getEvents() {
    return _db
        .collection(AppConstants.eventsCollection)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addEvent(EventModel event) async {
    await _db.collection(AppConstants.eventsCollection).add(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection(AppConstants.eventsCollection).doc(id).delete();
  }

  Future<void> updateEventRegistrations(
    String eventId,
    List<String> registrations,
  ) async {
    try {
      await _db.collection(AppConstants.eventsCollection).doc(eventId).update({
        'registeredUsers': registrations,
      });
    } catch (e) {
      throw "Failed to update registration: $e";
    }
  }

  Stream<List<ForumPostModel>> getForumPosts() {
    return _db
        .collection('forums')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ForumPostModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addForumPost(ForumPostModel post) async {
    await _db.collection('forums').add(post.toMap());
  }

  Stream<List<CommentModel>> getForumComments(String postId) {
    return _db
        .collection('forums')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addForumComment(String postId, CommentModel comment) async {
    final batch = _db.batch();
    final commentRef = _db
        .collection('forums')
        .doc(postId)
        .collection('comments')
        .doc();
    batch.set(commentRef, comment.toMap());
    final postRef = _db.collection('forums').doc(postId);
    batch.update(postRef, {'comments': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> toggleForumPostLike(String postId, String userId) async {
    // Basic implementation: just increment for now.
    // Usually we would check if user already liked, but for this mock-like structure increment is fine.
    await _db.collection('forums').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> syncForumCounts() async {
    try {
      final posts = await _db.collection('forums').get();
      for (var postDoc in posts.docs) {
        final comments = await postDoc.reference.collection('comments').get();
        await postDoc.reference.update({'comments': comments.docs.length});
      }
    } catch (e) {
      debugPrint("Error syncing forum counts: $e");
    }
  }

  Future<void> toggleBookmarkForumPost(String postId, String userId) async {
    final docRef = _db.collection('forums').doc(postId);
    final doc = await docRef.get();
    if (doc.exists) {
      final List<String> bookmarks = List<String>.from(
        doc.data()?['bookmarks'] ?? [],
      );
      if (bookmarks.contains(userId)) {
        await docRef.update({
          'bookmarks': FieldValue.arrayRemove([userId]),
        });
      } else {
        await docRef.update({
          'bookmarks': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  Stream<List<ChatConversationModel>> getConversations(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatConversationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    return _db
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(
    String conversationId,
    ChatMessageModel message,
    String lastMessage,
    String senderName,
  ) async {
    final batch = _db.batch();
    final messageRef = _db
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.toMap());
    final conversationRef = _db.collection('chats').doc(conversationId);
    batch.update(conversationRef, {
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.now(),
    });
    await batch.commit();
  }

  Future<String> createConversation(
    String selfId,
    String otherId,
    String selfName,
    String otherName,
  ) async {
    final ids = [selfId, otherId];
    ids.sort();
    final conversationId = ids.join('_');
    final doc = await _db.collection('chats').doc(conversationId).get();
    if (!doc.exists) {
      await _db.collection('chats').doc(conversationId).set({
        'participants': [selfId, otherId],
        'participantNames': {selfId: selfName, otherId: otherName},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return conversationId;
  }

  Stream<List<CommentModel>> getComments(String noticeId) {
    return _db
        .collection(AppConstants.noticesCollection)
        .doc(noticeId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addComment(String noticeId, CommentModel comment) async {
    final batch = _db.batch();

    final commentRef = _db
        .collection(AppConstants.noticesCollection)
        .doc(noticeId)
        .collection('comments')
        .doc();

    batch.set(commentRef, comment.toMap());

    final noticeRef = _db
        .collection(AppConstants.noticesCollection)
        .doc(noticeId);
    batch.update(noticeRef, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> syncAllCommentCounts() async {
    final notices = await _db.collection(AppConstants.noticesCollection).get();
    final batch = _db.batch();
    bool needsCommit = false;

    for (var doc in notices.docs) {
      final comments = await doc.reference.collection('comments').get();
      final count = comments.docs.length;
      final data = doc.data();

      if (data['commentCount'] != count) {
        batch.update(doc.reference, {'commentCount': count});
        needsCommit = true;
      }
    }

    if (needsCommit) {
      await batch.commit();
    }
  }

  Future<int> getUsersCount() async {
    try {
      final snapshot = await _db
          .collection(AppConstants.usersCollection)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint("Error getting users count: $e");
      return 0;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _db.collection(AppConstants.usersCollection).get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching all users: $e");
      return [];
    }
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearNotifications(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> toggleBookmarkLostFound(String itemId, String userId) async {
    final query = _db
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: itemId)
        .where('type', isEqualTo: 'lost_found');

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      await _db.collection('bookmarks').add({
        'userId': userId,
        'itemId': itemId,
        'type': 'lost_found',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> getBookmarkedLostFoundIds(String userId) {
    return _db
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'lost_found')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['itemId'] as String)
              .toList(),
        );
  }

  Future<int> getPendingApprovalsCount() async {
    try {
      final snapshot = await _db
          .collection(AppConstants.usersCollection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint("Error getting pending approvals: $e");
      return 0;
    }
  }

  Future<int> getActiveNoticesEventsCount() async {
    try {
      final notices = await _db
          .collection(AppConstants.noticesCollection)
          .count()
          .get();
      final events = await _db
          .collection(AppConstants.eventsCollection)
          .count()
          .get();
      return (notices.count ?? 0) + (events.count ?? 0);
    } catch (e) {
      debugPrint("Error getting active notices/events: $e");
      return 0;
    }
  }

  Future<int> getForumReportsCount() async {
    try {
      // Assuming a 'reports' collection exists for forum posts
      final snapshot = await _db.collection('reports').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint("Error getting forum reports: $e");
      return 0;
    }
  }
  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).delete();
    } catch (e) {
      debugPrint("Error deleting user: $e");
      throw e;
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).update({
        'status': status,
      });
    } catch (e) {
      debugPrint("Error updating user status: $e");
      throw e;
    }
  }
}
