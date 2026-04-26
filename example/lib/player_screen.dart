// example/lib/player_screen.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'polaroid_editor.dart';

class PlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String imageUrl;

  const PlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(() {
      // 재생/일시정지 등 상태가 변할 때마다 화면을 다시 그리도록 합니다.
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👈 상단 제목도 '음악 재생 & 폴라로이드'로 바꿨습니다!
      appBar: AppBar(title: const Text('음악 재생 & 폴라로이드')),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PolaroidEditor(
                      title: widget.title,
                      imageUrl: widget.imageUrl,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("음악 폴라로이드 만들기"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                backgroundColor: Colors.white10,
              ),
            ),
            // ✂️ 하단에 있던 AI 분석 결과 텍스트 박스(Card)를 통째로 삭제했습니다!
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}