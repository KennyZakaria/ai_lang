import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'providers/practice_provider.dart';
import 'screens/course_list_screen.dart';
import 'screens/lesson_list_screen.dart';
import 'screens/practice_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const NatulangApp());
}

class NatulangApp extends StatelessWidget {
  const NatulangApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use localhost for web, 10.0.2.2 for Android emulator
    final apiService = ApiService(baseUrl: 'http://localhost:8000');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PracticeProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Natulang - Language Learning',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Add routes for web navigation
        initialRoute: '/',
        routes: {
          '/': (context) => const CourseListScreen(),
          '/lessons': (context) => const LessonListScreen(),
          '/practice': (context) => const PracticeScreen(),
        },
      ),
    );
  }
}