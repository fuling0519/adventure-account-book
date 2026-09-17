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
  Widget build(BuildContext context) => MaterialApp(
        title: '冒險者錢袋',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppShell(),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;
  var _showCoin = false;

  static const _screens = <Widget>[MapScreen(), BackpackScreen(), JournalScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              reverseDuration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              // Prevents AnimatedSwitcher from briefly centering a short page.
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              transitionBuilder: (child, animation) => _PageTurnTransition(
                animation: animation,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
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
          ],
        ),
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
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: AppDestination.values
              .map((destination) => NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ))
              .toList(),
        ),
      );
}

class _PageTurnTransition extends StatelessWidget {
  const _PageTurnTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final value = animation.value;
          return FadeTransition(
            opacity: animation,
            child: Transform(
              alignment: Alignment.centerRight,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(0.075 * (1 - value)),
              child: child,
            ),
          );
        },
      );
}
