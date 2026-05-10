import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study/app/config.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qore',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),

        appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
      ),

      themeMode: ThemeMode.system,
      home: Config(),
      navigatorObservers: [BotToastNavigatorObserver()],
      builder: (context, child) {
        final wrapperChild = BotToastInit()(context, child);
        return wrapperChild;
      },
    );
  }
}
