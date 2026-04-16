import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import '../services/llm_service.dart';
import '../widgets/common_drawer.dart';
import '../screens/calendar_screen.dart';
import '../screens/summarization_screen.dart';
import '../models/daily_journal.dart';
import '../providers/journal_provider.dart'; // ✅ 이 줄이 꼭 있어야 함!
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _hasStopped = false;
  String _statusText = '···';

  List<DailyJournal> journalList = [];

  // TTS 초기화 함수
  Future<void> _initTts() async {
    // 플랫폼 확인 후 엔진 설정 (Android 전용)
    if (Platform.isAndroid) {
      try {
        await _tts.setEngine('com.google.android.tts');
        debugPrint('Android TTS engine set');
      } catch (e) {
        debugPrint('Failed to set Android TTS engine: $e');
      }
    }

    // iOS 특정 설정
    if (await _tts.isLanguageAvailable("en-US")) {
      await _tts.setLanguage("en-US");
    }
  }

  // 음성 인식 초기화 함수
  Future<void> _initSpeech() async {
    final result = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        setState(() {
          _statusText = status;
        });
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() {
          _statusText = 'Error: $error';
        });
      },
    );
    if (result) {
      debugPrint('Speech recognition initialized');
    } else {
      debugPrint('Speech recognition initialization failed');
    }
  }

  @override
  void initState() {
    super.initState();

    // TTS 초기화 및 설정
    _initTts();
    // 음성 인식 초기화
    _initSpeech();

    // Ensure TTS output plays through the iPhone speaker
    _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
    ]);

    // TTS 설정 - 자연스러운 음성을 위한 설정
    _tts.setSpeechRate(0.5); // 속도를 조금 낮춰 더 자연스럽게
    _tts.setVolume(1.0); // 최대 볼륨
    _tts.setPitch(1.1); // 약간 높은 피치로 더 생동감 있게

    // Trigger network access to prompt local network permission
    //sendToLlama("test connection");

    // Then begin normal conversation flow
    Future.delayed(Duration.zero, _startListening);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _statusText = '···';
      });

      await _speech.listen(
        onResult: (val) async {
          if (val.finalResult && _isListening) {
            final userSpeech = val.recognizedWords;

            // 음성 인식이 완료될 때마다 결과를 가져오되, 버튼으로 종료하기 전까지는 계속 수신
            debugPrint('Recognized: ${val.recognizedWords}');
          }
        },
        listenFor: const Duration(minutes: 10), // 최대 5분간 듣기 (실제로는 버튼으로 종료될 것임)
        pauseFor: const Duration(seconds: 30), // 일시 중지 시간을 늘려 자동 종료 방지
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: false, // 오류 발생 시에도 종료되지 않음
      );
    } else {
      setState(() => _statusText = 'Speech not available');
    }
  }

  // 음성 인식 정지 및 처리 함수
  Future<void> _stopListeningAndProcess() async {
    if (!_isListening) return;

    // 음성 인식 중지
    _speech.stop();

    setState(() {
      _isListening = false;
      _statusText = '···';
    });

    // 하드코딩된 예제 텍스트 (실제로는 인식된 음성을 사용해야 함)
    final userSpeech = _speech.lastRecognizedWords;
    // final userSpeech =
    //     "I had a really great day today. I started the morning with a cup of coffee while watching the sunrise, which made me feel calm and grateful. Later, I went for a walk in the park where the trees were blooming and birds were singing — it was peaceful and refreshing. I also bumped into an old friend and we ended up chatting for nearly an hour. In the evening, I had dinner with my family, and we laughed a lot while sharing stories from the week. I went to bed feeling happy and content.";

    if (userSpeech.trim().isEmpty) {
      print('⚠️ Empty prompt. Skipping LLM request.');
      return;
    }

    try {
      final response = await sendToLlama(
        "<|system|>You are an assistant that analyzes emotions in daily voice journals. "
        "Summarize the journal entry in 1–2 concise sentences. "
        "Then, on a new line, output only one word: positive, negative, or neutral. "
        "Respond in exactly two parts: the summary, then the one-word emotion. "
        "Do not add any punctuation or quotation marks.<|end|>"
        "<|user|>$userSpeech<|end|><|assistant|>",
      );

      // final response = await sendToLlama(
      //   "Summarize the following voice journal in 1–2 sentences. Then output either positive, negative, or neutral on a new line.\n\n$userSpeech",
      // );

      // final prompt = """
      // Please analyze the following journal entry.
      // First, summarize it in 1–2 concise sentences.
      // Then, on a new line, write only one word that describes the overall emotion: positive, negative, or neutral.

      // Journal:
      // $userSpeech

      // Response:
      // """;

      // final response = await sendToLlama(prompt);
      debugPrint(response);

      // Parse response into summary and emotion
      final lines = response.split('\n');
      final emotionLine = lines.isNotEmpty ? lines.last.trim().toLowerCase() : '';
      final emotion = emotionLine.contains('positive')
          ? 'positive'
          : emotionLine.contains('negative')
              ? 'negative'
              : emotionLine.contains('neutral')
                  ? 'neutral'
                  : 'neutral';

      final summary = lines.length > 1
          ? lines.sublist(0, lines.length - 1).join('\n').trim()
          : response.trim();

      // Create and save journal entry
      final now = DateTime.now();
      final journalEntry = DailyJournal(
        date: DateTime(now.year, now.month, now.day),
        summary: summary,
        emotion: emotion,
      );

      // Save to provider
      context.read<JournalProvider>().addJournal(journalEntry);

      // Debug print
      debugPrint('Journal Entry Saved: date=${journalEntry.date}, summary="${journalEntry.summary}", emotion="${journalEntry.emotion}"');

      void printInChunks(String label, String text) {
        const int chunkSize = 800;
        for (var i = 0; i < text.length; i += chunkSize) {
          final chunk = text.substring(
            i,
            i + chunkSize > text.length ? text.length : i + chunkSize,
          );
          print('$label: $chunk');
        }
      }

      printInChunks('📝 Summary', journalEntry.summary);

      print('📝 Summary: ${journalEntry.summary}');
      print('🧠 Emotion: ${journalEntry.emotion}');

      print('🧾 Raw LLM response:\n$response');
      print('🎤 userSpeech: $userSpeech');

      if (response.trim().isEmpty || !response.contains('\n')) {
        print('⚠️ Invalid LLM response: $response');
        return;
      }

      // iOS에서 Samantha 음성으로 설정 (더 자연스러운 발음)
      try {
        // 언어 설정
        await _tts.setLanguage("en-US");

        // Samantha 음성으로 직접 설정
        await _tts.setVoice({"name": "Samantha", "locale": "en-US"});
      } catch (e) {
        // 실패 시 기본 미국 영어로 설정
        await _tts.setLanguage("en-US");
      }

      await _tts.speak(response);

      setState(() {
        _hasStopped = true;
      });

      // Navigate to CalendarScreen after speaking
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => SummarizationScreen()),
        // );
      }
    } catch (e) {
      debugPrint('⚠️ Error during LLM response or TTS: $e');
      setState(() {
        _statusText = 'Error';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const CommonDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        toolbarHeight: 48,
      ),
      //body: Column(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 26),
            Center(
              child: Hero(
                tag: 'emo-image',
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: 0.7,
                    child: Image.asset(
                      'lib/src/Emo.png',
                      width: 400,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 53),
            if (!_hasStopped)
              Hero(
                tag: 'conversation-button',
                child: ElevatedButton(
                  onPressed: _isListening ? _stopListeningAndProcess : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA783E1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    'Stop Conversation',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
