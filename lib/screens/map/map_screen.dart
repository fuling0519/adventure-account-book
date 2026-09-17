import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../widgets/money_display.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatisticsProvider);
    final now = DateTime.now();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('☀️ 我的冒險', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${now.year} 年 ${now.month} 月 · 今日冒險旅程',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          const Card(
            color: Color(0xFFEAF3EE),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Column(children: [
                Text('前往下一個財務里程碑',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 22),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MapPoint(icon: '🏡', label: '出發地'),
                      _MapPath(),
                      _MapPoint(icon: '🌳', label: '旅途中'),
                      _MapPath(),
                      _MapPoint(icon: '🏰', label: '目標'),
                    ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('本月結餘'),
                    const SizedBox(height: 8),
                    MoneyDisplay(
                        amount: stats.balance,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                            minHeight: 10, value: stats.spendingRatio)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('收入 '),
                      MoneyDisplay(amount: stats.income),
                      const Text(' ／ 支出 '),
                      MoneyDisplay(amount: stats.expense),
                    ]),
                  ]),
            ),
          ),
          if (stats.income == 0 && stats.expense == 0) ...[
            const SizedBox(height: 22),
            const Card(
              color: Color(0xFFFFF5D9),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Text('🧭', style: TextStyle(fontSize: 34)),
                    SizedBox(height: 8),
                    Text('今天還沒有冒險',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('按下右下角的 +，記下一筆旅費吧！'),
                  ])),
            ),
          ],
        ]),
      ),
    );
  }
}

class _MapPoint extends StatelessWidget {
  const _MapPoint({required this.icon, required this.label});
  final String icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        Text(label, style: const TextStyle(fontSize: 11))
      ]);
}

class _MapPath extends StatelessWidget {
  const _MapPath();
  @override
  Widget build(BuildContext context) => const Expanded(
      child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Divider(color: Color(0xFF9CBDA9), thickness: 2)));
}
