import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_session/audio_session.dart';

// 關鍵修正：確保這兩個檔案被正確導入
import 'style_config.dart';
import 'camera_service.dart';

void main() => runApp(const DrivingApp());

class DrivingApp extends StatelessWidget {
  const DrivingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _currentSpeed = 0.0;
  bool _isOverSpeed = false;
  // 修正：確保 CameraService 已定義
  final CameraService _cameraService = CameraService();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  Future<void> _initSystem() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
    ));
    
    await _tts.setLanguage("zh-TW");
    await _cameraService.loadCameraData();

    // 關鍵修正：這裡移除了 const 關鍵字，解決圖四報錯
    Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      if (mounted) {
        setState(() {
          _currentSpeed = pos.speed * 3.6;
          _isOverSpeed = _currentSpeed > 105;
        });
        _checkDistance(pos);
      }
    });
  }

  void _checkDistance(Position pos) {
    for (var cam in _cameraService.allCameras) {
      double dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, cam.lat, cam.lng);
      if (dist < 500 && !cam.hasAlerted) {
        _tts.speak("注意，限速${cam.limit}");
        cam.hasAlerted = true;
      } else if (dist > 1000) {
        cam.hasAlerted = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.grey[900])),
          Positioned(
            left: 20,
            bottom: 40,
            child: _buildGlassPanel("${_currentSpeed.toInt()}", "KM/H"),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPanel(String val, String unit) {
    Color currentColor = _isOverSpeed ? GlassStyle.alertColor : GlassStyle.themeColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: currentColor.withAlpha(120), width: _isOverSpeed ? 2 : 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: GlassStyle.blurSigma, sigmaY: GlassStyle.blurSigma),
          child: Container(
            width: 170,
            height: 170,
            // 修正：使用 withAlpha 避免過時警告
            color: Colors.white.withAlpha((GlassStyle.glassOpacity * 255).toInt()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(val, style: TextStyle(fontSize: GlassStyle.speedFontSize, fontWeight: GlassStyle.speedFontWeight, color: currentColor)),
                Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}