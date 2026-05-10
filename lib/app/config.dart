import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/app/add_data.dart';
import 'package:study/app/app_provider.dart';
import 'package:study/features/root.dart';



class Config extends ConsumerWidget {
  const Config({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstTime = ref.watch(isFirstTimeProvider);
    return isFirstTime.when(
      data: (value) {
        if (value) {
          return const GettingStarted();
        }
        return const Root();
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: const Center(child: Text("Something went wrong")),
        );
      },
      loading: () {
        return Scaffold(body: const Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class GettingStarted extends ConsumerStatefulWidget {
  const GettingStarted({super.key});

  @override
  ConsumerState<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends ConsumerState<GettingStarted> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Text(appName, style: theme.textTheme.displaySmall)),
              const SizedBox(height: 15),
              Text(
                "Capture ideas. Stay productive.",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  try {
                    await ref
                        .read(isFirstTimeProvider.notifier)
                        .setFirstTimeCompleted();

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Root()),
                    );
                  } finally {}
                },
                child: const Text("Get Started"),
              ),
              const Spacer(),

              Text(
                "From",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                devTeam,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
