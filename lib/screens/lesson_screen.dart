import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/lesson.dart';
import '../services/ai_service.dart';
import '../services/youtube_service.dart';
import 'practice_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // ── AI STATE ──────────────────────────────────────────────
  bool _isLoadingAI = false;
  String _aiResponse = '';
  String _aiMode = ''; // 'examples' or 'explain'

  // ── YOUTUBE STATE ─────────────────────────────────────────
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();

    // WHY: We use a verified video ID and set up the controller
    // with proper flags to ensure it works on physical Android devices
    final videoId =
        YoutubeService.getVideoId(widget.lesson.id) ??
        'X9x0i6-j_gM'; // fallback to Intro to Matrices

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false, // WHY: captions sometimes cause loading issues
        forceHD: false, // WHY: force HD can cause buffering on mobile data
        loop: false,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  // ── TRIGGER AI ────────────────────────────────────────────
  Future<void> _triggerAI(String mode) async {
    setState(() {
      _isLoadingAI = true;
      _aiResponse = '';
      _aiMode = mode;
    });

    String response = '';

    if (mode == 'examples') {
      response = await AiService.generateMoreExamples(
        topicTitle: widget.lesson.title,
        explanation: widget.lesson.explanation,
        existingExample: widget.lesson.example,
      );
    } else if (mode == 'explain') {
      response = await AiService.explainFurther(
        topicTitle: widget.lesson.title,
        explanation: widget.lesson.explanation,
      );
    }

    setState(() {
      _isLoadingAI = false;
      _aiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF7B00FF),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),

          appBar: AppBar(
            backgroundColor: const Color(0xFF7B00FF),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Chapter ${widget.lesson.chapter}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. TITLE CARD ──────────────────────────
                _buildTitleCard(),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. EXPLANATION ──────────────────
                      _buildSectionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Explanation',
                        content: widget.lesson.explanation,
                        color: const Color(0xFF7B00FF),
                      ),
                      const SizedBox(height: 16),

                      // ── 3. EXAMPLE ──────────────────────
                      _buildSectionCard(
                        icon: Icons.calculate_rounded,
                        title: 'Example',
                        content: widget.lesson.example,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(height: 16),

                      // ── 4. AI SECTION ────────────────────
                      _buildAISection(),
                      const SizedBox(height: 16),

                      // ── 5. PRACTICE BUTTON ───────────────
                      _buildPracticeButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── 6. YOUTUBE VIDEO (always at bottom) ───
                _buildYoutubeSection(player),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  //  WIDGETS
  // ────────────────────────────────────────────────────────

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B00FF), Color(0xFF5500BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Topic ${widget.lesson.id}  •  ${widget.lesson.chapterTitle}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Text('🤖', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'AI Study Assistant',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Two AI buttons side by side
                Row(
                  children: [
                    // More Examples Button
                    Expanded(
                      child: _buildAIButton(
                        label: '➕ More Examples',
                        subtitle: 'Generate 2 new practice problems',
                        color: Colors.green.shade700,
                        isActive: _aiMode == 'examples',
                        onTap: _isLoadingAI
                            ? null
                            : () => _triggerAI('examples'),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Explain Further Button
                    Expanded(
                      child: _buildAIButton(
                        label: '💡 Explain More',
                        subtitle: 'Deeper explanation + tips',
                        color: Colors.orange.shade700,
                        isActive: _aiMode == 'explain',
                        onTap: _isLoadingAI
                            ? null
                            : () => _triggerAI('explain'),
                      ),
                    ),
                  ],
                ),

                // AI Response Area
                if (_isLoadingAI || _aiResponse.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Mode label
                  if (_aiMode.isNotEmpty)
                    Text(
                      _aiMode == 'examples'
                          ? '📝 AI-Generated Examples:'
                          : '💡 Further Explanation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _aiMode == 'examples'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Loading or response
                  if (_isLoadingAI)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.deepPurple),
                          SizedBox(height: 10),
                          Text(
                            'AI is working on it... 🧠',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        _aiResponse,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton({
    required String label,
    required String subtitle,
    required Color color,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: onTap == null ? Colors.grey : color,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B00FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.edit_note_rounded, size: 26),
        label: const Text(
          'Try Practice Question',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PracticeScreen(lesson: widget.lesson),
          ),
        ),
      ),
    );
  }

  Widget _buildYoutubeSection(Widget player) {
    final videoInfo = YoutubeService.getVideoForLesson(widget.lesson.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.red, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Video Lecture',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YouTube',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // YouTube Player (full width, no horizontal padding)
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: player,
        ),

        // Video info below player
        if (videoInfo != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  videoInfo['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  videoInfo['channel'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
