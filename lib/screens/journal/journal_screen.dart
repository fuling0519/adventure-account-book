import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../transaction/transaction_form.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final categories =
        ref.watch(categoryProvider).valueOrNull ?? const <Category>[];
    final categoryMap = {
      for (final category in categories) category.id: category
    };
    return SafeArea(
      child: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('讀取冒險紀錄失敗：$error')),
        data: (items) => CustomScrollView(
          slivers: [
            const SliverAppBar(title: Text('📜 冒險紀錄'), pinned: true),
            if (items.isEmpty)
              const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('還沒有冒險紀錄\n按下 + 開始記帳')))
            else
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final category = categoryMap[item.categoryId];
                  final income = item.type == TransactionType.income;
                  return ListTile(
                    leading: Text(category?.icon ?? '📦',
                        style: const TextStyle(fontSize: 24)),
                    title: Text(item.note?.isNotEmpty == true
                        ? item.note!
                        : category?.name ?? '其他'),
                    subtitle: Text(
                        '${item.date.year}/${item.date.month}/${item.date.day}'),
                    trailing: Text('${income ? '+' : '-'}${item.amount}',
                        style: TextStyle(
                            color: income
                                ? Colors.green.shade700
                                : Colors.deepOrange.shade400,
                            fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final saved = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => TransactionForm(transaction: item),
                      );
                      if (saved == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✨ 冒險紀錄已更新')),
                        );
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
