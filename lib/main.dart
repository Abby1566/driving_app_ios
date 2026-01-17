import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 導入語音套件
import 'package:audio_session/audio_session.dart'; // 導入音訊管理

void main() => runApp(const DrivingApp());

class DrivingApp extends StatelessWidget {
  const DrivingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.dark(),
    home: const Dashboard(),
  );
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 1. 定義語音引擎變數
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initAudioSettings(); // 啟動時初始化音訊
  }

  // 2. 初始化音訊設定 (壓低音樂關鍵)
  Future<void> _initAudioSettings() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers, // 這行就是壓低音樂
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ));
    
    // 設定語音為台灣中文
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);     // 音調 (1.0 是正常)
    await flutterTts.setSpeechRate(0.5); // 語速 (0.5 比較清晰)
  }

  // 3. 觸發播報的函式
  Future<void> _announceSpeedCam(String type, int limit) async {
    String message = "注意，前方五百公尺有$type照相，限速$limit公里。";
    await flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 模擬地圖背景
          Positioned.fill(child: Container(color: Colors.grey[900])),
          
          // 測試按鈕：點了就會說話並壓低音樂
          Center(
            child: ElevatedButton(
              onPressed: () => _announceSpeedCam("固定式", 100),
              child: const Text("測試語音播報"),
            ),
          ),

          // 你的 Liquid Glass 儀表板... (保留原本的 _buildGlassPanel)
        ],
      ),
    );
  }
}