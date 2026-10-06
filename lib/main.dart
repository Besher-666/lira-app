import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // استيراد المكتبة
import 'app_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // تحميل ملف الـ env السري
  runApp(const SyrianCurrencyConverterApp());
}

class SyrianCurrencyConverterApp extends StatefulWidget {
  const SyrianCurrencyConverterApp({super.key});

  @override
  State<SyrianCurrencyConverterApp> createState() =>
      _SyrianCurrencyConverterAppState();
}

class _SyrianCurrencyConverterAppState
    extends State<SyrianCurrencyConverterApp> {
  bool _isEnglish = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _isEnglish ? const Locale('en', 'US') : const Locale('ar', 'SY'),
      supportedLocales: const [Locale('ar', 'SY'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: Colors.deepPurple,
      ),
      home: AppNavigation(
        isEnglish: _isEnglish,
        onLanguageChanged: (isEnglish) {
          setState(() => _isEnglish = isEnglish);
        },
      ),
    );
  }
}
