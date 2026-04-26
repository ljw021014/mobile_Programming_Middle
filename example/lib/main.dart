// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경변수(.env) 로드용
import 'youtube_service.dart'; // 유튜브 통신 서비스
import 'player_screen.dart'; // 재생 화면

void main() async {
  // 플러터 엔진이 실행되기 전에 .env 파일을 먼저 읽어오도록 설정
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Search App',
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
      ),
      home: const SearchScreen(),
    );
  }
}

// 검색 화면 클래스
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _youTubeService = YouTubeService();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // 검색 버튼을 눌렀을 때 실행될 함수
  void _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _youTubeService.searchMusic(_searchController.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // 'print' 대신 'debugPrint'를 사용하여 운영 모드 경고 해결
      debugPrint("검색 에러: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음악 검색하기')),
      body: Column(
        children: [
          // 1. 상단 검색창
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
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, size: 30, color: Colors.cyanAccent),
                  onPressed: _performSearch,
                ),
              ],
            ),
          ),

          // 2. 검색 결과 리스트
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                final snippet = item['snippet'];

                // 썸네일 고화질 주소 가져오기 (없으면 기본 화질)
                final thumbnailUrl = snippet['thumbnails']['high']?['url'] ??
                    snippet['thumbnails']['default']['url'];

                // 특수문자 변환
                final title = snippet['title']
                    .replaceAll('&quot;', '"')
                    .replaceAll('&#39;', "'");
                final channelTitle = snippet['channelTitle'];

                return ListTile(
                  leading: Image.network(thumbnailUrl, width: 60, fit: BoxFit.cover),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(channelTitle),
                  onTap: () {
                    final videoId = item['id']['videoId'];

                    // ✅ 해결: 'song.imageUrl' 대신 추출한 'thumbnailUrl'을 사용합니다.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          videoId: videoId,
                          title: title,
                          imageUrl: thumbnailUrl,
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