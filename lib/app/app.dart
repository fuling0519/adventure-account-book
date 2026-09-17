import 'package:flutter/material.dart';

import '../screens/backpack/backpack_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/transaction/transaction_form.dart';
import 'router.dart';
import 'theme.dart';

class AdventurerPouchApp extends StatelessWidget {
  const AdventurerPouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '冒險者錢袋',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;
  var _showCoin = false;

  static const _screens = <Widget>[
    MapScreen(),
    BackpackScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
                      .animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
              key: ValueKey(_selectedIndex), child: _screens[_selectedIndex]),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
          right: _showCoin ? 34 : MediaQuery.sizeOf(context).width / 2 - 18,
          top: _showCoin ? MediaQuery.sizeOf(context).height - 100 : 88,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _showCoin ? 1 : 0,
            child: const Text('🪙', style: TextStyle(fontSize: 32)),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            builder: (_) => const TransactionForm(),
          );
          if (saved == true && context.mounted) {
            setState(() => _showCoin = true);
            Future<void>.delayed(const Duration(milliseconds: 720), () {
              if (mounted) setState(() => _showCoin = false);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✨ 冒險紀錄已保存')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: AppDestination.values
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
