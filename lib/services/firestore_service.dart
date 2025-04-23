import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/translation_history.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _historyCollection =>
      _firestore.collection('translation_history');

  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get user document reference
  DocumentReference get _userDoc => _usersCollection.doc(currentUserId);

  // Create or update user profile
  Future<void> updateUserProfile({
    required String name,
    String? email,
  }) async {
    if (currentUserId == null) return;

    await _userDoc.set({
      'name': name,
      'email': email ?? _auth.currentUser?.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update user's avatar
  Future<void> updateUserAvatar(String avatarId) async {
    if (currentUserId == null) return;

    await _userDoc.update({
      'avatarId': avatarId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      DocumentSnapshot doc = await _userDoc.get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        // Create a basic profile if it doesn't exist
        String? email = _auth.currentUser?.email;
        String? displayName = _auth.currentUser?.displayName ?? 'User';

        await _userDoc.set({
          'name': displayName,
          'email': email,
          'avatarId': 'avatar1', // Default avatar
          'createdAt': FieldValue.serverTimestamp(),
        });

        return {
          'name': displayName,
          'email': email,
          'avatarId': 'avatar1',
        };
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Add a translation to history
  Future<void> addTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required String translationType, // 'text', 'image', or 'voice'
  }) async {
    if (currentUserId == null) return;

    // Create a document reference with auto-generated ID
    DocumentReference docRef = _historyCollection.doc();

    // Create history object
    Map<String, dynamic> historyData = {
      'id': docRef.id,
      'userId': currentUserId,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': FieldValue.serverTimestamp(),
      'type': translationType, // Add translation type
    };

    // Save to Firestore
    await docRef.set(historyData);
  }

  // Get history for current user, optionally filtered by type
  Stream<List<TranslationHistory>> getTranslationHistory({String? type}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _historyCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true);

    // Apply type filter if specified
    if (type != null && type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Convert Timestamp to DateTime
        Timestamp timestamp = data['timestamp'] as Timestamp;
        data['timestamp'] = timestamp.toDate();

        return TranslationHistory.fromMap(data);
      }).toList();
    });
  }

  // Delete a translation from history
  Future<void> deleteTranslation(String historyId) async {
    await _historyCollection.doc(historyId).delete();
  }

  // Clear all history for current user
  Future<void> clearHistory() async {
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final snapshots = await _historyCollection
        .where('userId', isEqualTo: currentUserId)
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
