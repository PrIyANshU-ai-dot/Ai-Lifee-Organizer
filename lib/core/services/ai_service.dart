import 'dart:convert';

import 'package:ai_life_organizer/core/config/env_config.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/generated_task.dart';
import 'package:dio/dio.dart';

/// Contract for the AI task generation service.
/// Implementations can be mock (MVP) or real API.
abstract class AiService {
  /// Generates structured tasks for a goal. Returns list of [GeneratedTask].
  Future<List<GeneratedTask>> generateTasks({
    required String goalTitle,
    required DateTime deadline,
  });
}

/// Mock AI service that returns predefined structured task JSON.
/// Used for MVP; replace with real API implementation later.
class MockAiService implements AiService {
  @override
  Future<List<GeneratedTask>> generateTasks({
    required String goalTitle,
    required DateTime deadline,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Mock structured response matching real API shape
    const String mockJson = '''
    {
      "tasks": [
        {"title": "Break down goal into milestones", "order": 1},
        {"title": "Research and gather resources", "order": 2},
        {"title": "Create action plan", "order": 3},
        {"title": "Set weekly checkpoints", "order": 4},
        {"title": "Review and adjust progress", "order": 5}
      ]
    }
    ''';

    final Map<String, dynamic> decoded = jsonDecode(mockJson) as Map<String, dynamic>;
    final List<dynamic> tasksJson = decoded['tasks'] as List<dynamic>;

    return tasksJson
        .map((e) => GeneratedTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Dio-based AI service for real API (placeholder for future).
class DioAiService implements AiService {
  DioAiService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: EnvConfig.aiServiceBaseUrl));

  final Dio _dio;

  @override
  Future<List<GeneratedTask>> generateTasks({
    required String goalTitle,
    required DateTime deadline,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/generate-tasks',
      data: {
        'goal_title': goalTitle,
        'deadline': deadline.toIso8601String(),
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${EnvConfig.aiServiceApiKey}'},
      ),
    );

    final data = response.data;
    if (data == null || !data.containsKey('tasks')) {
      throw Exception('Invalid AI service response');
    }

    final List<dynamic> tasksJson = data['tasks'] as List<dynamic>;
    return tasksJson
        .map((e) => GeneratedTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
