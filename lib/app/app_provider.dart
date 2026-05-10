import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isFirstTimeProvider = AsyncNotifierProvider<IsFirstTimeNotifier, bool>(
  () {
    return IsFirstTimeNotifier();
  },
);

class IsFirstTimeNotifier extends AsyncNotifier<bool> {
  static const _key = "first-time";

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await prefs.setBool(_key, false);
      return false;
    });
  }
}
