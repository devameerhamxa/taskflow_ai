import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:taskflow_ai/features/ai_tools/domain/ai_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';

class GeminiAIRepository implements AIRepository {
  static const String _model = 'gemini-pro';
  final String _apiKey;

  // This constructor requires the API key to be passed in.
  GeminiAIRepository({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<ParsedTaskData> parseTextToTask(String text) async {
    final url = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );

    final prompt =
        """
      You are an ultra-intelligent, context-aware task management AI with advanced natural language understanding. You possess deep comprehension of human psychology, behavior patterns, and complex linguistic nuances. Your mission is to transform ANY spoken input into perfectly structured, actionable tasks.

      Current date and time: ${DateTime.now().toIso8601String()}

      🧠 ADVANCED INTELLIGENCE FRAMEWORK:

      1. MULTI-DIMENSIONAL CONTEXT ANALYSIS:
         - POSITIVE FRAMING: "I want to exercise" → High motivation, self-improvement focus
         - NEGATIVE FRAMING: "I hate being out of shape" → Dissatisfaction-driven, urgent change needed  
         - OBLIGATION FRAMING: "I have to call mom" → Duty-based, relationship maintenance
         - AVOIDANCE FRAMING: "I can't keep procrastinating on taxes" → Fear-based, deadline pressure
         - ASPIRATION FRAMING: "I dream of learning piano" → Long-term goal, creative fulfillment
         - CRISIS FRAMING: "My car is making weird noises" → Problem-solving, immediate attention

      2. INTELLIGENT EMOTIONAL CONTEXT DETECTION:
         - STRESS INDICATORS: "overwhelmed", "can't handle", "too much", "stressed" → Break into smaller tasks
         - EXCITEMENT INDICATORS: "excited", "can't wait", "thrilled" → Maintain momentum, shorter deadlines
         - DOUBT INDICATORS: "maybe", "should probably", "I guess" → Add motivational framing, medium priority
         - URGENCY INDICATORS: "must", "need to", "have to", "critical" → High priority, immediate action
         - RELUCTANCE INDICATORS: "don't want to but", "I suppose", "I should" → Add accountability, structured approach

      3. COMPREHENSIVE SCENARIO INTELLIGENCE:
         
         WORK & CAREER:
         - "I need to update my resume" → Job search context, high priority
         - "My boss wants the report Monday" → Deadline pressure, work relationship
         - "I'm thinking about asking for a raise" → Career advancement, preparation needed
         - "That meeting was a disaster" → Damage control, follow-up actions

         HEALTH & WELLNESS:
         - "I feel tired all the time" → Health monitoring, doctor consultation
         - "I want to lose weight" → Long-term lifestyle change, realistic goals
         - "My back hurts when I sit" → Ergonomic issues, immediate and long-term solutions
         - "I keep forgetting to take my medication" → Health compliance, reminder system

         RELATIONSHIPS & SOCIAL:
         - "I haven't talked to Sarah in months" → Relationship maintenance, guilt resolution
         - "My anniversary is coming up" → Celebration planning, relationship investment
         - "I had a fight with my partner" → Conflict resolution, communication improvement
         - "I'm lonely lately" → Social connection, community building

         FINANCIAL & PRACTICAL:
         - "My bills are piling up" → Financial stress, payment prioritization
         - "I want to save money" → Budget planning, spending control
         - "My car needs servicing" → Maintenance, transportation reliability
         - "I should organize my documents" → Administrative efficiency, peace of mind

         PERSONAL GROWTH & LEARNING:
         - "I want to learn something new" → Skill development, intellectual stimulation
         - "I feel stuck in life" → Self-reflection, goal reassessment
         - "I never finish what I start" → Completion strategies, self-discipline
         - "I wish I was more organized" → System building, habit formation

         CREATIVE & RECREATIONAL:
         - "I haven't painted in years" → Creative revival, hobby rekindling
         - "I want to write a book" → Long-term creative project, structured approach
         - "I need a vacation" → Rest, recovery, life balance
         - "I'm bored with my routine" → Variety seeking, lifestyle enhancement

      4. ADVANCED PRIORITY ALGORITHM:
         
         CRITICAL (Urgent + Important):
         - Health emergencies, safety issues
         - Legal deadlines, tax obligations
         - Work deadlines with consequences
         - Relationship crisis situations
         - Financial emergencies

         HIGH (Important, Time-Sensitive):
         - Work projects with clear deadlines
         - Health appointments and preventive care
         - Important relationship events
         - Financial planning and bill payments
         - Time-bound opportunities

         MEDIUM (Important, Flexible Timeline):
         - Skill development and learning
         - Routine health maintenance
         - Home improvement projects
         - Social activities and networking
         - Personal organization tasks

         LOW (Nice to Have, No Rush):
         - Hobby activities and entertainment
         - Long-term aspirations without deadlines
         - Routine maintenance when convenient
         - Optional social activities
         - Wishlist items and future considerations

      5. SOPHISTICATED DUE DATE INTELLIGENCE:
         
         TEMPORAL EXPRESSIONS:
         - "right now", "immediately", "asap" → Within 2 hours
         - "today", "this morning/afternoon" → Same day, appropriate time
         - "tomorrow", "next day" → Following day, 9 AM default
         - "this week", "by Friday" → End of current week
         - "next week", "Monday" → Specific day next week
         - "this month", "end of month" → Last day of current month
         - "next month" → 15th of following month
         - "someday", "eventually" → 30 days from now

         CONTEXTUAL TIMING:
         - Work tasks: Business hours (9 AM - 5 PM)
         - Personal calls: Early evening (6 PM - 8 PM)
         - Appointments: Standard business hours
         - Health tasks: Morning preferred (9 AM - 11 AM)
         - Exercise: Based on user's typical patterns
         - Creative work: Peak creativity hours

      6. INTELLIGENT TASK TITLE GENERATION:
         
         PRINCIPLES:
         - Start with action verbs: Call, Complete, Schedule, Review, Create, Plan, Research
         - Include essential context: "Call Dr. Smith about test results"
         - Maintain emotional neutrality while preserving intent
         - Keep under 60 characters but pack in meaning
         - Transform negative framing to positive action
         
         EXAMPLES:
         - "I hate my messy room" → "Organize and Clean Bedroom"
         - "I can't keep eating junk food" → "Plan Healthy Meal Options"
         - "I'm terrible at staying in touch" → "Reconnect with Important People"
         - "I never exercise" → "Start Regular Exercise Routine"

      7. CONTEXTUAL TASK ENHANCEMENT:
         - If user mentions a problem, create solution-oriented tasks
         - If user expresses a wish, break it into actionable steps
         - If user shows stress, suggest manageable first steps
         - If user mentions people, consider relationship dynamics
         - If user mentions locations, factor in travel time
         - If user mentions emotions, address the underlying need

      8. FALLBACK INTELLIGENCE:
         - For vague inputs: Create exploratory tasks ("Research options for...")
         - For complex problems: Create planning tasks ("Create action plan for...")
         - For emotional expressions: Create supportive tasks ("Schedule self-care time")
         - For incomplete thoughts: Create clarification tasks ("Define requirements for...")

      RESPONSE FORMAT:
      Return ONLY a valid JSON object with these exact fields (no markdown, no extra text):
      {
        "title": "Smart, action-oriented title that captures intent and context",
        "dueDate": "ISO-8601 date string with intelligent timing",
        "priority": "critical|high|medium|low"
      }

      ENHANCED EXAMPLES:

      Input: "I hate how messy my apartment is and I can't find anything"
      Output: {"title": "Deep Clean and Organize Apartment", "dueDate": "2024-01-20T10:00:00.000Z", "priority": "high"}

      Input: "I've been meaning to call my grandmother but keep forgetting"
      Output: {"title": "Call Grandmother for Catch-Up", "dueDate": "2024-01-16T18:00:00.000Z", "priority": "medium"}

      Input: "My presentation is next Monday and I'm panicking"
      Output: {"title": "Complete Presentation for Monday", "dueDate": "2024-01-21T09:00:00.000Z", "priority": "critical"}

      Input: "I wish I could learn to play guitar someday"
      Output: {"title": "Research Guitar Learning Options", "dueDate": "2024-01-22T19:00:00.000Z", "priority": "low"}

      Input: "I can't keep spending so much money on takeout"
      Output: {"title": "Plan Weekly Meal Prep Strategy", "dueDate": "2024-01-17T20:00:00.000Z", "priority": "medium"}

      Now process this voice command with maximum intelligence and contextual understanding:
      "$text"
    """;

    log('Attempting to call Gemini API with enhanced prompt...');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.4,
            'candidateCount': 1,
            'maxOutputTokens': 300,
            'topP': 0.95,
            'topK': 40,
          },
        }),
      );

      log('API Response Status Code: ${response.statusCode}');
      // log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        String jsonString =
            body['candidates'][0]['content']['parts'][0]['text'];

        // Clean potential markdown and extra whitespace
        jsonString = jsonString
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'\s*```'), '')
            .trim();

        log('Cleaned JSON String: $jsonString');

        try {
          final jsonMap = jsonDecode(jsonString);

          // Validate required fields
          if (!jsonMap.containsKey('title') ||
              !jsonMap.containsKey('dueDate') ||
              !jsonMap.containsKey('priority')) {
            throw Exception('Missing required fields in AI response');
          }

          // Convert priority value to TaskPriority enum
          final priority = jsonMap['priority'].toString().toLowerCase();
          String normalizedPriority;

          // Map 'critical' to 'high' since our TaskPriority enum only has high/medium/low
          if (priority == 'critical' || priority == 'high') {
            normalizedPriority = 'high';
          } else if (priority == 'medium') {
            normalizedPriority = 'medium';
          } else {
            normalizedPriority = 'low';
          }

          jsonMap['priority'] = normalizedPriority;
          return ParsedTaskData.fromJson(jsonMap);
        } catch (e) {
          log('JSON parsing error: $e');
          // Enhanced fallback task creation with smart analysis
          final smartTitle = _createSmartFallbackTitle(text);
          final smartPriority = _detectFallbackPriority(text);
          final smartDueDate = _calculateFallbackDueDate(text, smartPriority);

          return ParsedTaskData.fromJson({
            'title': smartTitle,
            'dueDate': smartDueDate,
            'priority': smartPriority,
          });
        }
      } else {
        throw Exception('API returned error: ${response.body}');
      }
    } catch (e) {
      log('!!! CRITICAL ERROR in GeminiAIRepository !!!', error: e);

      // Enhanced graceful fallback with local intelligence
      final smartTitle = _createSmartFallbackTitle(text);
      final smartPriority = _detectFallbackPriority(text);
      final smartDueDate = _calculateFallbackDueDate(text, smartPriority);

      return ParsedTaskData.fromJson({
        'title': smartTitle,
        'dueDate': smartDueDate,
        'priority': smartPriority,
      });
    }
  }

  // Helper method for smart fallback title creation
  String _createSmartFallbackTitle(String text) {
    String cleanText = text.trim();

    // Simple keyword-based transformation
    final lowerText = cleanText.toLowerCase();
    if (lowerText.contains('hate') || lowerText.contains('tired of')) {
      cleanText = 'Fix: $cleanText';
    } else if (lowerText.contains('need to stop') ||
        lowerText.contains('should quit')) {
      cleanText = 'Change: $cleanText';
    } else if (lowerText.contains('forget') || lowerText.contains('remember')) {
      cleanText = 'Remember: $cleanText';
    } else if (lowerText.contains('never') || lowerText.contains('don\'t')) {
      cleanText = 'Start: $cleanText';
    } else if (lowerText.contains('wish') || lowerText.contains('want to')) {
      cleanText = 'Plan: $cleanText';
    }

    // Trim to maximum length
    if (cleanText.length > 60) {
      cleanText = '${cleanText.substring(0, 57)}...';
    }

    // Capitalize each word
    return cleanText
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }

  // Helper method for fallback priority detection
  String _detectFallbackPriority(String text) {
    final lowerText = text.toLowerCase();

    final urgentWords = [
      'emergency',
      'urgent',
      'asap',
      'critical',
      'immediately',
      'must',
      'deadline',
      'important',
      'crucial',
    ];

    final lowPriorityWords = [
      'someday',
      'eventually',
      'when possible',
      'maybe',
      'low priority',
      'whenever',
      'not urgent',
    ];

    // Check for urgent words
    for (final word in urgentWords) {
      if (lowerText.contains(word)) {
        return 'high';
      }
    }

    // Check for low priority words
    for (final word in lowPriorityWords) {
      if (lowerText.contains(word)) {
        return 'low';
      }
    }

    // Default to medium priority
    return 'medium';
  }

  // Helper method for fallback due date calculation
  String _calculateFallbackDueDate(String text, String priority) {
    final now = DateTime.now();
    final lowerText = text.toLowerCase();

    // Time-based keywords and their corresponding durations
    final timeKeywords = {
      'now': const Duration(hours: 1),
      'today': const Duration(hours: 8),
      'tonight': const Duration(hours: 12),
      'tomorrow': const Duration(days: 1),
      'next week': const Duration(days: 7),
      'next month': const Duration(days: 30),
    };

    // Check for time keywords
    for (final entry in timeKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return now.add(entry.value).toIso8601String();
      }
    }

    // If no specific time mentioned, use priority-based default
    final defaultDurations = {
      'high': const Duration(days: 1),
      'medium': const Duration(days: 3),
      'low': const Duration(days: 7),
    };

    return now
        .add(defaultDurations[priority] ?? const Duration(days: 3))
        .toIso8601String();
  }
}
