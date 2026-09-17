import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class MoneyDisplay extends StatelessWidget {
  const MoneyDisplay({super.key, required this.amount, this.style});
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      key: ValueKey(amount),
      tween: IntTween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) =>
          Text('\$${formatMoney(value)}', style: style),
    );
  }
}
