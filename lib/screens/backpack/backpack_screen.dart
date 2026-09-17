import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/money_display.dart';

class BackpackScreen extends ConsumerWidget {
  const BackpackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatisticsProvider);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(title: Text('🎒 冒險者背包'), pinned: true),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(children: [
              _SummaryCard(
                  label: '本月收入',
                  value: stats.income,
                  icon: '💰',
                  color: Colors.green.shade700),
              const SizedBox(height: 12),
              _SummaryCard(
                  label: '本月支出',
                  value: stats.expense,
                  icon: '🪙',
                  color: Colors.deepOrange.shade400),
              const SizedBox(height: 12),
              _SummaryCard(
                  label: '本月結餘',
                  value: stats.balance,
                  icon: '🏕️',
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 28),
              Text('本月支出分類', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (stats.byCategory.isEmpty)
                const Card(
                    child: Padding(
                        padding: EdgeInsets.all(20), child: Text('本月還沒有支出分類')))
              else
                ...stats.byCategory.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            Row(children: [
                              Text(item.category.icon,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item.category.name)),
                              Text(
                                  '\$${formatMoney(item.amount)}  ${(item.ratio * 100).round()}%'),
                            ]),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(value: item.ratio),
                          ]),
                        ),
                      ),
                    )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final int value;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Text(label)),
          MoneyDisplay(
              amount: value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }
}
