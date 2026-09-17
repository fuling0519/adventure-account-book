import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key, this.transaction});

  final AppTransaction? transaction;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  String? _categoryId;
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _date = transaction.date;
      _categoryId = transaction.categoryId;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(List<Category> categories) async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final transaction = AppTransaction(
      id: widget.transaction?.id,
      type: _type,
      amount: int.parse(_amountController.text.trim()),
      categoryId: _categoryId!,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
    );
    if (_isEditing) {
      await ref.read(transactionProvider.notifier).edit(transaction);
    } else {
      await ref.read(transactionProvider.notifier).add(transaction);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除冒險紀錄'),
        content: const Text('確定要刪除這筆冒險紀錄嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('確定刪除')),
        ],
      ),
    );
    if (confirmed != true || widget.transaction?.id == null) return;
    await ref
        .read(transactionProvider.notifier)
        .remove(widget.transaction!.id!);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);
    return categoriesAsync.when(
      loading: () => const SizedBox(
          height: 280, child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('無法載入分類：$error'),
      ),
      data: (categories) {
        final visibleCategories =
            categories.where((item) => item.type == _type).toList();
        _categoryId ??=
            visibleCategories.isEmpty ? null : visibleCategories.first.id;
        return SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 24),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 20),
                  Text(_isEditing ? '編輯冒險紀錄' : '新增冒險紀錄',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('支出'),
                          icon: Icon(Icons.remove)),
                      ButtonSegment(
                          value: TransactionType.income,
                          label: Text('收入'),
                          icon: Icon(Icons.add)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selected) => setState(() {
                      _type = selected.first;
                      _categoryId = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: '金額', prefixText: '\$ '),
                    validator: (value) {
                      final amount = int.tryParse(value?.trim() ?? '');
                      return amount == null || amount <= 0
                          ? '請輸入大於 0 的金額'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: '類別'),
                    items: visibleCategories
                        .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text('${category.icon} ${category.name}')))
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                    validator: (value) => value == null ? '請選擇類別' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('日期'),
                    subtitle: Text('${_date.year}/${_date.month}/${_date.day}'),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: _date);
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                  TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: '備註（選填）')),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                      onPressed: _saving ? null : () => _save(categories),
                      icon: const Icon(Icons.check),
                      label: Text(_saving ? '保存中…' : '完成冒險')),
                  if (_isEditing) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _saving ? null : _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('刪除這筆紀錄'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700),
                    ),
                  ],
                ]),
          ),
        );
      },
    );
  }
}
