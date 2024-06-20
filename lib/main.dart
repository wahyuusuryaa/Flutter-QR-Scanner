import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkTheme') ?? false) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = _themeMode == ThemeMode.dark;

    // Perbarui status tema dalam `setState`
    setState(() {
      _themeMode = isDarkTheme ? ThemeMode.light : ThemeMode.dark;
    });

    // Simpan status tema secara async setelah `setState`
    await prefs.setBool('isDarkTheme', !isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: ScanScreen(toggleTheme: _toggleTheme),
    );
  }
}