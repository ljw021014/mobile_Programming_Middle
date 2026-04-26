// example/lib/player_screen.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // env 파일 읽기용
import 'package:google_generative_ai/google_generative_ai.dart'; // 제미나이 AI

class PlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const PlayerScreen({Key? key, required this.videoId, required this.title}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late YoutubePlayerController _controller;
  String _recommendedGame = "아직 분석 전입니다.";

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🎮 똑똑해진 AI 게임 추천 로직!
  void _analyzeMoodAndRecommendGame() async {
    setState(() {
      _recommendedGame = "🤔 AI가 노래 분위기를 분석 중입니다...\n잠시만 기다려주세요!";
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        setState(() { _recommendedGame = "🚨 에러: Gemini API 키를 찾을 수 없습니다."; });
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // 가장 표준적인 이름입니다.
        apiKey: apiKey,
      );

      final prompt = """
        너는 전 세계의 음악과 비디오 게임을 모두 알고 있는 최고의 콘텐츠 큐레이터야.
        지금 사용자가 듣고 있는 노래는 '${widget.title}' 이야.
        
        1. 이 노래의 전반적인 분위기나 장르를 1줄로 요약해줘.
        2. 이 노래의 분위기와 가장 잘 어울리는 비디오 게임 딱 1개를 추천해줘.
        3. 왜 이 게임을 추천했는지 1~2줄로 설명해줘.
        
        결과는 이모지를 섞어서 친근하고 깔끔하게 한국어로 출력해.
      """;

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _recommendedGame = response.text ?? "결과를 가져오지 못했습니다.";
      });

    } catch (e) {
      setState(() {
        _recommendedGame = "🚨 분석 중 에러가 발생했습니다: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음악 재생 & 분위기 분석')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MiniMusicVisualizer(color: Colors.cyanAccent, width: 6, height: 30, animate: _controller.value.isPlaying,),
                const SizedBox(width: 10),
                MiniMusicVisualizer(color: Colors.purpleAccent, width: 6, height: 30, animate: _controller.value.isPlaying,),
                const SizedBox(width: 10),
                MiniMusicVisualizer(color: Colors.pinkAccent, width: 6, height: 30, animate: _controller.value.isPlaying,),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _analyzeMoodAndRecommendGame,
              icon: const Icon(Icons.sports_esports),
              label: const Text("이 노래에 어울리는 게임 추천받기!"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(20),
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _recommendedGame,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}