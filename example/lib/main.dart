// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경변수(.env) 로드용
import 'youtube_service.dart'; // 아까 만든 통신병
import 'player_screen.dart'; // 👈 이 줄을 추가!

void main() async {
  // ⭐️ 플러터 엔진이 실행되기 전에 .env 파일을 먼저 읽어오도록 하는 매우 중요한 코드입니다!
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // 👈 이렇게 변경!

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Search App',
      theme: ThemeData.dark(), // 음악 앱 느낌이 나게 어두운 테마 적용!
      home: const SearchScreen(),
    );
  }
}

// 검색 화면 클래스
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key); // 👈 이렇게 변경!

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _youTubeService = YouTubeService(); // 통신병 소환

  List<dynamic> _searchResults = []; // 검색 결과를 담을 바구니
  bool _isLoading = false; // 로딩 빙글빙글 도는 상태

  // 검색 버튼을 눌렀을 때 실행될 함수
  void _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // 유튜브에 검색 요청하고 결과를 기다림
      final results = await _youTubeService.searchMusic(_searchController.text);
      setState(() {
        _searchResults = results; // 결과를 바구니에 담음
      });
    } catch (e) {
      print("검색 에러: $e");
    } finally {
      setState(() {
        _isLoading = false; // 로딩 끝
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음악 검색하기')),
      body: Column(
        children: [
          // 1. 상단 검색창 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '듣고 싶은 노래를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(), // 엔터키 눌러도 검색되게
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: _performSearch, // 돋보기 눌러도 검색
                ),
              ],
            ),
          ),

          // 2. 하단 검색 결과 리스트 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // 로딩 중일 땐 빙글빙글
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                final snippet = item['snippet'];

                // JSON 데이터에서 썸네일, 제목, 채널 이름만 쏙쏙 뽑아오기
                final thumbnailUrl = snippet['thumbnails']['default']['url'];
                // 유튜브 제목에 섞여있는 특수문자 변환
                final title = snippet['title'].replaceAll('&quot;', '"').replaceAll('&#39;', "'");
                final channelTitle = snippet['channelTitle'];

                return ListTile(
                  leading: Image.network(thumbnailUrl, fit: BoxFit.cover), // 썸네일 이미지
                  title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis // 글자가 길면 ... 으로 자르기
                  ),
                  subtitle: Text(channelTitle),
                  onTap: () {
                    // TODO: 나중에 여기를 누르면 노래가 재생되고 분위기를 분석할 겁니다!
                    final videoId = item['id']['videoId'];
                    final songTitle = title;

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              videoId: videoId,
                              title: songTitle,
                            ),
                        ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}