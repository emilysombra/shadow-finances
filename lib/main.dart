import 'package:flutter/material.dart';

void main() {
  runApp(const ShadowFinancesApp());
}

class ShadowFinancesApp extends StatelessWidget {
  const ShadowFinancesApp({super.key});

  static const String title = 'Shadow Finances';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Text(ShadowFinancesApp.title, style: textTheme.headlineMedium),
      ),
    );
  }
}
