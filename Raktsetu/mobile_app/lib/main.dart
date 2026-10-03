import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BloodDonorFinderApp());
}

class BloodDonorFinderApp extends StatelessWidget {
  const BloodDonorFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD90429);

    return MaterialApp(
      title: 'RaktSetu Blood Donor Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
