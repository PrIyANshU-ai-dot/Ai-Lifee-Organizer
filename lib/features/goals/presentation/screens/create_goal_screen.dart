import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_life_organizer/core/utils/date_utils.dart';
import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';

/// Screen to create a goal: title, deadline; calls AI service (mock) and stores goal + tasks in Firestore.
class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Clear any previous error before validating and submitting.
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      setState(() => _errorMessage = 'Please pick a deadline');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    debugPrint(
      '[CreateGoalScreen] Creating goal with title="${_titleController.text.trim()}" '
      'and deadline=$_deadline',
    );

    try {
      final user = await ref.read(currentUserOnceProvider.future);
      if (!mounted) return;
      if (user == null) {
        debugPrint(
          '[CreateGoalScreen] No authenticated Firebase user found. Aborting goal creation.',
        );
        setState(() {
          _isLoading = false;
          _errorMessage = 'You must be signed in to create a goal.';
        });
        return;
      }

      final repo = ref.read(goalsRepositoryProvider);
      debugPrint('[CreateGoalScreen] Creating goal...');
      await repo.createGoalWithTasks(
        userId: user.id,
        title: _titleController.text.trim(),
        deadline: _deadline!,
      );
      debugPrint('[CreateGoalScreen] Goal created successfully');

      if (!mounted) return;

      setState(() => _isLoading = false);
      context.pop();
    } catch (e) {
      debugPrint('[CreateGoalScreen] Error while creating goal: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Goal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal title',
                      hintText: 'e.g. Learn Flutter',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter a goal title';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) setState(() => _deadline = date);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_deadline == null
                        ? 'Pick date'
                        : AppDateUtils.toDisplayDate(_deadline!)),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const LoadingOverlay(message: 'Generating tasks...')
                  else
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: const Text('Create goal & generate tasks'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
