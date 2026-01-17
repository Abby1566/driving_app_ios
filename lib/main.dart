// --- 步驟 A：導入所有必要的零件 ---
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // GPS 套件
import 'package:flutter_tts/flutter_tts.dart'; // 語音套件
import 'package:audio_session/audio_session.dart'; // 音訊管理

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
  // --- 定義變數 ---
  double _currentSpeed = 0.0; 
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _startTrackingSpeed(); // 啟動時開始追蹤 GPS
  }

  // --- 步驟 B：GPS 時速獲取邏輯 ---
  Future<void> _startTrackingSpeed() async {
    // 請求權限
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // 監聽位置與時速
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        setState(() {
          // 將 m/s 轉換為 KM/H
          _currentSpeed = position.speed * 3.6;
          if (_currentSpeed < 0) _currentSpeed = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 模擬地圖背景
          Positioned.fill(
            child: Container(color: Colors.grey[900]),
          ),

          // 核心 UI：Liquid Glass 玻璃測速儀
          Positioned(
            left: 20,
            bottom: 40,
            child: _buildGlassPanel(160, 160, "${_currentSpeed.toInt()}", "KM/H"),
          ),
        ],
      ),
    );
  }

  // 玻璃面板繪製函式
  Widget _buildGlassPanel(double w, double h, String mainText, String subText) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mainText, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  Text(subText, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}