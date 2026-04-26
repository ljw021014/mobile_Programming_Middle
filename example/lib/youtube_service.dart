// example/lib/youtube_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<dynamic>> searchMusic(String query) async {
    try {
      final apiKey = dotenv.env['YOUTUBE_API_KEY'];

      // 👇 이 줄을 추가해서 콘솔창에 진짜 키가 잘 나오는지 확인해 봅니다!
      print('🔑 현재 앱이 인식한 API 키: $apiKey');

      if (apiKey == null || apiKey.isEmpty) {
        print('🚨 환경변수 에러: API 키를 찾을 수 없습니다. .env 파일을 확인하세요.');
        return [];
      }

      // 2. 한글 & 띄어쓰기가 인터넷 주소에서 깨지지 않게 변환 (매우 중요!)
      final encodedQuery = Uri.encodeComponent('$query 음악');
      final url = '$_baseUrl/search?part=snippet&maxResults=5&q=$encodedQuery&type=video&key=$apiKey';

      // 유튜브에 요청 보내기
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'];
      } else {
        print('🚨 API 에러: 유튜브에서 거절했습니다. (코드: ${response.statusCode})');
        print('거절 상세 이유: ${response.body}');
        return [];
      }
    } catch (e) {
      print('🚨 시스템 에러: $e');
      return [];
    }
  }
}