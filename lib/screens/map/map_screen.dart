import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/money_display.dart';
import '../transaction/transaction_form.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatisticsProvider);
    final transactions =
        ref.watch(transactionProvider).valueOrNull ?? const <AppTransaction>[];
    final categories = ref.watch(categoryProvider).valueOrNull ?? const <Category>[];
    final categoryMap = {for (final category in categories) category.id: category};
    final now = DateTime.now();
    final recent = transactions.take(3).toList();
    final thisMonth = transactions
        .where((item) => item.date.year == now.year && item.date.month == now.month)
        .toList();

    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey('map-scroll'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Text('☀️ 我的冒險', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('${now.year} 年 ${now.month} 月 · 今日冒險旅程',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF71827B))),
                const SizedBox(height: 20),
                _MilestoneCard(transactionCount: thisMonth.length, balance: stats.balance, income: stats.income),
                const SizedBox(height: 16),
                _BalanceCard(stats: stats),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('最近紀錄', style: Theme.of(context).textTheme.titleLarge),
                  if (recent.isNotEmpty)
                    Text('最新 3 筆', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF71827B))),
                ]),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  const _EmptyRecentCard()
                else
                  Card(
                    child: Column(children: [
                      for (var index = 0; index < recent.length; index++) ...[
                        _RecentTransactionTile(transaction: recent[index], category: categoryMap[recent[index].categoryId]),
                        if (index != recent.length - 1)
                          const Divider(height: 1, indent: 58, endIndent: 16),
                      ],
                    ]),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.transactionCount, required this.balance, required this.income});
  final int transactionCount;
  final int balance;
  final int income;

  @override
  Widget build(BuildContext context) {
    final firstRecorded = transactionCount >= 1;
    final fiveRecorded = transactionCount >= 5;
    final positiveBalance = income > 0 && balance >= 0;
    final completed = [firstRecorded, fiveRecorded, positiveBalance].where((done) => done).length;
    final message = !firstRecorded
        ? '記下第一筆收支，展開本月旅程'
        : !fiveRecorded
            ? '再記 ${5 - transactionCount} 筆，抵達補給站'
            : !positiveBalance
                ? '本月維持正餘額，前往財務里程碑'
                : '本月里程碑已完成，繼續前進！';
    return Card(
      color: const Color(0xFFE4F0E7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE1A83D), size: 17),
            const SizedBox(width: 7),
            const Expanded(child: Text('本月財務里程碑', style: TextStyle(fontWeight: FontWeight.w800))),
            Text('$completed / 3', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4F8772))),
          ]),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerLeft, child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF668076)))),
          const SizedBox(height: 16),
          Row(children: [
            _MilestonePoint(label: '啟程', icon: Icons.edit_note_rounded, complete: firstRecorded),
            _MilestonePath(complete: fiveRecorded),
            _MilestonePoint(label: '補給', icon: Icons.backpack_rounded, complete: fiveRecorded),
            _MilestonePath(complete: positiveBalance),
            _MilestonePoint(label: '目標', icon: Icons.flag_rounded, complete: positiveBalance),
          ]),
        ]),
      ),
    );
  }
}

class _MilestonePoint extends StatelessWidget {
  const _MilestonePoint({required this.label, required this.icon, required this.complete});
  final String label;
  final IconData icon;
  final bool complete;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 47,
        child: Column(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: complete ? const Color(0xFF5F9B82) : const Color(0xFFFFFDF8), shape: BoxShape.circle),
            child: Icon(complete ? Icons.check_rounded : icon, size: 18, color: complete ? Colors.white : const Color(0xFF5F9B82)),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF587167))),
        ]),
      );
}

class _MilestonePath extends StatelessWidget {
  const _MilestonePath({required this.complete});
  final bool complete;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(height: 2, decoration: BoxDecoration(color: complete ? const Color(0xFF5F9B82) : const Color(0xFFAFCCBA), borderRadius: BorderRadius.circular(2))),
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.stats});
  final MonthlyStatistics stats;
  @override
  Widget build(BuildContext context) {
    final hasIncome = stats.income > 0;
    final progress = hasIncome ? stats.spendingRatio : 0.0;
    final status = !hasIncome
        ? '新增收入後，就能看見補給狀態'
        : stats.balance >= 0
            ? '補給狀態良好 · ${(100 - progress * 100).round()}% 尚可運用'
            : '本月支出超過收入，先檢視補給吧';
    return Card(
      color: const Color(0xFFFFF4DE),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('本月結餘', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF756C5C))),
          const SizedBox(height: 6),
          MoneyDisplay(amount: stats.balance, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 33)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFE9DDC5),
              valueColor: AlwaysStoppedAnimation(stats.balance < 0 ? const Color(0xFFD48268) : const Color(0xFFE5AF46)),
            ),
          ),
          const SizedBox(height: 7),
          Text(status, style: const TextStyle(fontSize: 12, color: Color(0xFF7C735F))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _AmountLabel(label: '收入', amount: stats.income, color: const Color(0xFF4F8772))),
            Container(width: 1, height: 26, color: const Color(0xFFE5D9C0)),
            Expanded(child: _AmountLabel(label: '支出', amount: stats.expense, color: const Color(0xFFC56D57))),
          ]),
        ]),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  const _AmountLabel({required this.label, required this.amount, required this.color});
  final String label;
  final int amount;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF7C735F))),
        const SizedBox(height: 2),
        Text('\$${formatMoney(amount)}', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
      ]);
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({required this.transaction, required this.category});
  final AppTransaction transaction;
  final Category? category;
  @override
  Widget build(BuildContext context) {
    final income = transaction.type == TransactionType.income;
    final categoryName = category?.name ?? '其他';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: income ? const Color(0xFFE2F0E6) : const Color(0xFFF8E9D8), borderRadius: BorderRadius.circular(10)),
        child: Text(category?.icon ?? '◌', style: const TextStyle(fontSize: 18)),
      ),
      title: Text(transaction.note?.isNotEmpty == true ? transaction.note! : categoryName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text('${transaction.date.month} 月 ${transaction.date.day} 日 · $categoryName', style: const TextStyle(fontSize: 11)),
      trailing: Text('${income ? '+' : '−'}${formatMoney(transaction.amount)}', style: TextStyle(fontWeight: FontWeight.w800, color: income ? const Color(0xFF4F9870) : const Color(0xFFC96E58))),
      onTap: () => showModalBottomSheet<bool>(context: context, isScrollControlled: true, builder: (_) => TransactionForm(transaction: transaction)),
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard();
  @override
  Widget build(BuildContext context) => const Card(
        color: Color(0xFFFFF4DE),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(children: [
            Text('🧭', style: TextStyle(fontSize: 26)),
            SizedBox(width: 12),
            Expanded(child: Text('還沒有冒險紀錄，點右下角 + 收好第一筆補給。')),
          ]),
        ),
      );
}
