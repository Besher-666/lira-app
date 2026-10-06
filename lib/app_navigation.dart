import 'package:flutter/material.dart';
import 'converter_screen.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ConverterScreen(
        isEnglish: widget.isEnglish,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      _ComingSoonScreen(isEnglish: widget.isEnglish),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 50,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: widget.isEnglish ? 'Converter' : 'المحول',
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: widget.isEnglish ? 'More' : 'المزيد',
          ),
        ],
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'More' : 'المزيد'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          isEnglish ? 'This screen is coming soon' : 'هذه الشاشة قادمة قريباً',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }
}
