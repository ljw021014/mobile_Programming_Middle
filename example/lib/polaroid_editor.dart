import 'dart:io'; // 혹시 몰라서 남겨둠 (플랫폼 확인용 등)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PolaroidEditor extends StatefulWidget {
  final String title;
  final String imageUrl;

  const PolaroidEditor({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<PolaroidEditor> createState() => _PolaroidEditorState();
}

class _PolaroidEditorState extends State<PolaroidEditor> {
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<String> _presetQuotes = [
    "이 리듬에 내 하루를 맡겨본다",
    "찬란했던 우리의 순간들이 떠오르는 곡",
    "오늘 밤, 나를 위로해 주는 단 하나의 멜로디",
    "무한 반복 중... 빠져나올 수 없어",
    "눈을 감고 들으면 새로운 세상이 펼쳐져",
    "비 오는 날, 커피 한 잔과 이 노래",
  ];

  String _selectedQuote = "";
  bool _isCustomQuote = false;

  final TextEditingController _customQuoteController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedQuote = _presetQuotes[0];
  }

  Future<void> _captureAndShare() async {
    try {
      final directory = (await getApplicationDocumentsDirectory()).path;
      final String fileName = 'polaroid_${DateTime.now().millisecondsSinceEpoch}.png';

      await _screenshotController.captureAndSave(directory, fileName: fileName);
      final String imagePath = '$directory/$fileName';

      await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🎵 오늘의 음악 조각\n#${widget.title.replaceAll(' ', '')} #MusicPolaroid'
      );
    } catch (e) {
      debugPrint("공유 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 핵심 UX 디테일: 화면 전체를 GestureDetector로 감싸서 터치를 감지합니다.
    return GestureDetector(
      onTap: () {
        // 빈 공간을 누르면 현재 올라와 있는 키보드를 스윽 내립니다.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          title: const Text('기억 조각 만들기', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(10, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey,
                              child: const Icon(Icons.music_note, size: 50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Text(
                        _selectedQuote,
                        style: GoogleFonts.nanumMyeongjo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      Text(
                        _memoController.text.isEmpty ? "오늘의 감정을 기록해보세요..." : _memoController.text,
                        style: GoogleFonts.nanumPenScript(
                          fontSize: 24,
                          color: Colors.blueGrey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          DateTime.now().toString().split(' ')[0].replaceAll('-', '.'),
                          style: GoogleFonts.courierPrime(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("✒️ 나만의 기록 남기기", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _memoController,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "이 노래를 들으니 어떤 기분인가요?",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("💬 문구 선택", style: TextStyle(color: Colors.white, fontSize: 16)),
                        Switch(
                          value: _isCustomQuote,
                          activeThumbColor: Colors.cyanAccent,
                          activeTrackColor: Colors.cyanAccent.withValues(alpha: 0.3),
                          onChanged: (val) {
                            setState(() {
                              _isCustomQuote = val;
                              if (val) {
                                _selectedQuote = _customQuoteController.text.isEmpty
                                    ? "여기에 가사를 입력하세요"
                                    : _customQuoteController.text;
                              } else {
                                _selectedQuote = _presetQuotes[0];
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    _isCustomQuote
                        ? TextField(
                      controller: _customQuoteController,
                      onChanged: (val) => setState(() => _selectedQuote = val),
                      style: const TextStyle(color: Colors.cyanAccent),
                      decoration: InputDecoration(
                        hintText: "기억에 남는 가사를 직접 적어보세요",
                        hintStyle: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                      ),
                    )
                        : SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetQuotes.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedQuote == _presetQuotes[index];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedQuote = _presetQuotes[index]),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.cyanAccent : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  _presetQuotes[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _captureAndShare,
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text("이 순간 박제하기 (공유)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}