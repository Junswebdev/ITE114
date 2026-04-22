import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // 👇 OPENROUTER API KEY
  static const String _apiKey =
      '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';

  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  // ─── GENERATE MORE EXAMPLES ──────────────────────────────
  // WHY: Very strict prompt that forces Gemini to output
  // real numbered math problems with step-by-step solutions.

  static Future<String> generateMoreExamples({
    required String topicTitle,
    required String explanation,
    required String existingExample,
  }) async {
    final String prompt =
        '''
You are a Linear Algebra professor creating exam practice problems.

TOPIC: $topicTitle

TASK: Generate exactly 2 NEW worked examples for this topic.

STRICT RULES:
- Use ONLY real numbers (integers or simple fractions)
- Show EVERY calculation step — do not skip any steps
- Each example must be different from this existing one:
  "$existingExample"
- Format EXACTLY as shown below — do not deviate

FORMAT TO FOLLOW:
━━━━━━━━━━━━━━━━━━━━━
EXAMPLE A
━━━━━━━━━━━━━━━━━━━━━
Problem: [write the specific math problem here]

Solution:
Step 1: [first step with actual calculation]
Step 2: [second step with actual calculation]
Step 3: [continue until solved]
Answer: [final answer clearly stated]

━━━━━━━━━━━━━━━━━━━━━
EXAMPLE B
━━━━━━━━━━━━━━━━━━━━━
Problem: [write a harder specific math problem here]

Solution:
Step 1: [first step with actual calculation]
Step 2: [second step with actual calculation]
Step 3: [continue until solved]
Answer: [final answer clearly stated]

IMPORTANT:
- Example A should be EASY (simple small numbers)
- Example B should be MEDIUM difficulty
- Every number in the solution must be calculated explicitly
- Do NOT write generic descriptions — write ACTUAL MATH
''';

    return await _callGemini(prompt, maxTokens: 1000);
  }

  // ─── EXPLAIN FURTHER ─────────────────────────────────────
  static Future<String> explainFurther({
    required String topicTitle,
    required String explanation,
  }) async {
    final String prompt =
        '''
You are a friendly math tutor explaining to a Filipino college student.

TOPIC: $topicTitle

CURRENT EXPLANATION THEY HAVE:
$explanation

YOUR TASK — Write a deeper explanation using this EXACT structure:

🔑 THE CORE IDEA IN ONE SENTENCE:
[Write one simple sentence that captures the whole concept]

🏠 REAL-LIFE ANALOGY:
[Describe a real-world situation a Filipino student can relate to
that works exactly like this math concept. Be specific and creative.]

⚠️ COMMON MISTAKES STUDENTS MAKE:
Mistake 1: [describe a specific common error]
Why it's wrong: [brief explanation]

Mistake 2: [describe another specific common error]  
Why it's wrong: [brief explanation]

💡 MEMORY TRICK:
[Give one specific trick, rhyme, acronym, or visual method
to remember this concept]

Keep the total response under 280 words.
Use simple, friendly language. No complex notation.
''';

    return await _callGemini(prompt, maxTokens: 600);
  }

  // ─── CHECK STUDENT ANSWER ────────────────────────────────
  // WHY: Strict prompt so AI gives clear CORRECT/INCORRECT
  // verdict and shows exact solution when wrong.

  static Future<String> checkAnswer({
    required String topicTitle,
    required String question,
    required String studentAnswer,
  }) async {
    final String prompt =
        '''
You are a Linear Algebra professor grading a student's answer.

TOPIC: $topicTitle
QUESTION ASKED: $question
STUDENT'S SUBMITTED ANSWER: $studentAnswer

GRADING TASK:
First, solve the problem yourself completely.
Then compare with the student's answer.

RESPOND USING THIS EXACT FORMAT:

VERDICT: [Write only one of: ✅ CORRECT | ❌ INCORRECT | 🔶 PARTIALLY CORRECT]

SCORE: [X out of 10]

YOUR EVALUATION:
[2-3 sentences explaining what the student got right or wrong.
Be specific — reference their actual answer.]

CORRECT SOLUTION:
Step 1: [first step]
Step 2: [second step]
Step 3: [continue until complete]
Final Answer: [clearly state the answer]

FEEDBACK FOR STUDENT:
[Write 1-2 encouraging sentences. If wrong, tell them exactly
which step to review. If correct, tell them what they did well.]

Keep your tone kind, specific, and encouraging.
Remember: this is a college student who is learning.
''';

    return await _callGemini(prompt, maxTokens: 800);
  }

  // ─── PRIVATE: CALL OPENROUTER API ────────────────────────────
  static Future<String> _callGemini(
    String prompt, {
    int maxTokens = 800,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: json.encode({
              'model': 'google/gemini-2.0-flash-001',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.3,
              'max_tokens': maxTokens,
              'top_p': 0.8,
            }),
          )
          .timeout(
            // WHY: 30 second timeout so app doesn't hang forever
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if response has choices
        if (data['choices'] == null || data['choices'].isEmpty) {
          return '⚠️ AI could not generate a response for this topic. '
              'Please try again.';
        }

        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 400) {
        return '❌ Invalid API request. '
            'Please check your API key in ai_service.dart.\n'
            'Error: ${response.body}';
      } else if (response.statusCode == 401) {
        return '❌ API key is invalid or expired.\n'
            'Go to openrouter.ai to get a new key.\n'
            'Then update it in lib/services/ai_service.dart';
      } else if (response.statusCode == 403) {
        return '❌ API key is invalid or expired.\n'
            'Go to openrouter.ai to get a new key.\n'
            'Then update it in lib/services/ai_service.dart';
      } else if (response.statusCode == 429) {
        return '⏳ Too many requests. '
            'Please wait 30 seconds and try again.';
      } else {
        return '❌ AI Error ${response.statusCode}.\n'
            'Details: ${response.body}';
      }
    } on Exception catch (e) {
      if (e.toString().contains('timed out')) {
        return '⏳ Request timed out.\n'
            'Your internet connection may be slow. Please try again.';
      }
      return '❌ Connection error: $e\n'
          'Make sure you have internet connection and try again.';
    }
  }
}
