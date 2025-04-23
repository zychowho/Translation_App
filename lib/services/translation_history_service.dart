import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/translation_history.dart';

class TranslationHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _historyCollection =>
      _firestore.collection('translation_history');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add a translation to history
  Future<void> addTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    String type = 'text',
  }) async {
    if (currentUserId == null) return;

    // Create a document reference with auto-generated ID
    DocumentReference docRef = _historyCollection.doc();

    // Create history object
    TranslationHistory history = TranslationHistory(
      id: docRef.id,
      userId: currentUserId!,
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
      type: type,
    );

    // Save to Firestore
    await docRef.set(history.toMap());
  }

  // Get history for current user
  Stream<List<TranslationHistory>> getTranslationHistory() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _historyCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TranslationHistory.fromMap(doc.data() as Map<String, dynamic>);
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
