import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해 추가

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<dynamic>> searchMusic(String query) async {
    try {
      final apiKey = dotenv.env['YOUTUBE_API_KEY'];

      // 💡 운영 환경 권장사항: print 대신 debugPrint를 사용합니다.
      debugPrint('🌐 유튜브 검색 서비스 호출 중...');

      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('🚨 에러: YOUTUBE_API_KEY가 .env 파일에 없습니다.');
        return [];
      }

      // 검색 결과의 정확도를 높이기 위해 쿼리 뒤에 '음악' 키워드를 자동으로 조합합니다.
      final encodedQuery = Uri.encodeComponent('$query 음악');
      final url = '$_baseUrl/search?part=snippet&maxResults=5&q=$encodedQuery&type=video&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'];
      } else {
        // 에러 발생 시 상세한 내용을 로그로 남겨 디버깅을 돕습니다.
        debugPrint('🚨 유튜브 API 호출 실패 (상태 코드: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      debugPrint('🚨 시스템 예외 발생: $e');
      return [];
    }
  }
}