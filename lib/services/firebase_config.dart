class FirebaseConfig {
  // Project details
  static const String projectName = 'TranslationApp';
  static const String projectId = 'translationapp-b0d7f';
  static const String projectNumber = '375188955953';
  static const String webApiKey = 'AIzaSyBtYVCL8-MYlWoDBsCuX3uCq3UMdQbMEqA';

  // Firebase configuration
  static const Map<String, String> webConfig = {
    'apiKey': webApiKey,
    'authDomain': '$projectId.firebaseapp.com',
    'databaseURL': 'https://$projectId.firebaseio.com',
    'projectId': projectId,
    'storageBucket': '$projectId.appspot.com',
    'messagingSenderId': projectNumber,
    'appId':
        '1:$projectNumber:web:12345abcdef', // This should be replaced with the actual app ID
  };

  // Firestore security rules template (to be implemented in Firebase Console)
  static const String firestoreRules = '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Users collection rules
        match /users/{userId} {
          // Allow read/write only to the authenticated user that owns the document
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        
        // Translation history rules
        match /translation_history/{historyId} {
          // Allow users to read/write their own translation history
          allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
                            
          // Allow users to create new history with their user ID
          allow create: if request.auth != null && 
                        request.resource.data.userId == request.auth.uid;
        }
      }
    }
  ''';
}
