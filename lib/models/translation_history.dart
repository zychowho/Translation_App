class TranslationHistory {
  final String id;
  final String userId;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final String type; // 'text', 'image', or 'voice'

  TranslationHistory({
    required this.id,
    required this.userId,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.type,
  });

  // Convert to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp,
      'type': type,
    };
  }

  // Create a TranslationHistory from a Firestore snapshot
  factory TranslationHistory.fromMap(Map<String, dynamic> map) {
    return TranslationHistory(
      id: map['id'],
      userId: map['userId'],
      originalText: map['originalText'],
      translatedText: map['translatedText'],
      sourceLanguage: map['sourceLanguage'],
      targetLanguage: map['targetLanguage'],
      timestamp: map['timestamp'],
      type:
          map['type'] ?? 'text', // Default to 'text' for backward compatibility
    );
  }
}
