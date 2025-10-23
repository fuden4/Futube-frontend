import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FutubeApp());
}

class FutubeApp extends StatelessWidget {
  const FutubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFB20710),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0F0F0F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F0F),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1A1A),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
