import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/ai_service.dart';

class PracticeScreen extends StatefulWidget {
  final Lesson lesson;
  const PracticeScreen({super.key, required this.lesson});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isCheckingAnswer = false;
  String _aiFeedback = '';
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // ── SUBMIT ANSWER TO AI ──────────────────────────────────
  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✏️ Please write your answer first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingAnswer = true;
      _aiFeedback = '';
      _hasSubmitted = true;
    });

    final feedback = await AiService.checkAnswer(
      topicTitle: widget.lesson.title,
      question: widget.lesson.practiceQuestion,
      studentAnswer: answer,
    );

    setState(() {
      _isCheckingAnswer = false;
      _aiFeedback = feedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF7B00FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Practice Question',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7B00FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Topic ${widget.lesson.id}: ${widget.lesson.title}',
                style: const TextStyle(
                  color: Color(0xFF7B00FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── QUESTION CARD ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Row(
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        color: Color(0xFF7B00FF),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Question',
                        style: TextStyle(
                          color: Color(0xFF7B00FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.lesson.practiceQuestion,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── ANSWER INPUT ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Your Answer',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Write your full solution below. '
                    'Show your working step by step.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // Text input field
                  TextField(
                    controller: _answerController,
                    maxLines: 8,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF2D2D2D),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Write your answer here...\n\n'
                          'Example format:\n'
                          'Step 1: ...\n'
                          'Step 2: ...\n'
                          'Answer: ...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── SUBMIT BUTTON ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: _isCheckingAnswer
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('🤖', style: TextStyle(fontSize: 20)),
                label: Text(
                  _isCheckingAnswer
                      ? 'AI is checking your answer...'
                      : 'Submit for AI Review',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isCheckingAnswer ? null : _submitAnswer,
              ),
            ),
            const SizedBox(height: 20),

            // ── AI FEEDBACK CARD ─────────────────────────
            if (_hasSubmitted) ...[
              if (_isCheckingAnswer)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.deepPurple),
                      SizedBox(height: 16),
                      Text(
                        '🤖 AI is reviewing your answer...',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'This may take a few seconds',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_aiFeedback.isNotEmpty)
                Container(
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
                      // Feedback header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade50,
                              Colors.purple.shade50,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text('🤖', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 8),
                            Text(
                              'AI Feedback',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Feedback content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _aiFeedback,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),

                      // Try Again button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text(
                              'Try Again with New Answer',
                              style: TextStyle(fontSize: 14),
                            ),
                            onPressed: () {
                              setState(() {
                                _answerController.clear();
                                _aiFeedback = '';
                                _hasSubmitted = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
