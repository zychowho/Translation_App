import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:translation_app/models/translation_history.dart';
import 'package:translation_app/services/translation_history_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TranslationHistoryService _historyService = TranslationHistoryService();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _speakingId = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _speakingId = '';
        });
      }
    });
  }

  Future<void> _speak(String text, String language, String id) async {
    if (_isSpeaking) {
      await _flutterTts.stop();

      if (_speakingId == id) {
        setState(() {
          _isSpeaking = false;
          _speakingId = '';
        });
        return;
      }
    }

    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);

    setState(() {
      _isSpeaking = true;
      _speakingId = id;
    });
  }

  String _formatDate(DateTime timestamp) {
    return DateFormat('MMM d, yyyy · h:mm a').format(timestamp);
  }

  String _getLanguageName(String code) {
    final Map<String, String> languageMap = {
      'auto': 'Auto-detect',
      'af': 'Afrikaans',
      'sq': 'Albanian',
      'am': 'Amharic',
      'ar': 'Arabic',
      'hy': 'Armenian',
      'eu': 'Basque',
      'bn': 'Bengali',
      'bg': 'Bulgarian',
      'ca': 'Catalan',
      'ny': 'Chichewa',
      'zh-cn': 'Chinese (Simplified)',
      'zh-tw': 'Chinese (Traditional)',
      'hr': 'Croatian',
      'cs': 'Czech',
      'da': 'Danish',
      'nl': 'Dutch',
      'en': 'English',
      'et': 'Estonian',
      'tl': 'Filipino',
      'fi': 'Finnish',
      'fr': 'French',
      'de': 'German',
      'el': 'Greek',
      'gu': 'Gujarati',
      'ha': 'Hausa',
      'iw': 'Hebrew',
      'hi': 'Hindi',
      'hu': 'Hungarian',
      'is': 'Icelandic',
      'ig': 'Igbo',
      'id': 'Indonesian',
      'it': 'Italian',
      'ja': 'Japanese',
      'kn': 'Kannada',
      'km': 'Khmer',
      'ko': 'Korean',
      'la': 'Latin',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'ms': 'Malay',
      'ml': 'Malayalam',
      'mr': 'Marathi',
      'my': 'Myanmar (Burmese)',
      'ne': 'Nepali',
      'no': 'Norwegian',
      'pl': 'Polish',
      'pt': 'Portuguese',
      'ro': 'Romanian',
      'ru': 'Russian',
      'sr': 'Serbian',
      'si': 'Sinhala',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'es': 'Spanish',
      'sw': 'Swahili',
      'sv': 'Swedish',
      'ta': 'Tamil',
      'te': 'Telugu',
      'th': 'Thai',
      'tr': 'Turkish',
      'uk': 'Ukrainian',
      'ur': 'Urdu',
      'vi': 'Vietnamese',
      'cy': 'Welsh',
      'yo': 'Yoruba',
      'zu': 'Zulu'
    };

    return languageMap[code] ?? code;
  }

  Future<void> _confirmDeleteAll() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History'),
        content: Text(
            'Are you sure you want to delete your entire translation history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _historyService.clearHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation history cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Translation History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _confirmDeleteAll,
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: StreamBuilder<List<TranslationHistory>>(
        stream: _historyService.getTranslationHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final historyItems = snapshot.data ?? [];

          if (historyItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No translation history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your translations will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];

              return Dismissible(
                key: Key(item.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _historyService.deleteTranslation(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Translation deleted')),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_getLanguageName(item.sourceLanguage)} → ${_getLanguageName(item.targetLanguage)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(item.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          item.originalText,
                          style: TextStyle(fontSize: 16),
                        ),
                        Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.translatedText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isSpeaking && _speakingId == item.id
                                    ? Icons.stop
                                    : Icons.volume_up,
                                color: _isSpeaking && _speakingId == item.id
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              onPressed: () => _speak(
                                item.translatedText,
                                item.targetLanguage,
                                item.id,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
