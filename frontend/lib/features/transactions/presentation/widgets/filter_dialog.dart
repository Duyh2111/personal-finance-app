import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';

class FilterDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? categories;

  const FilterDialog({
    super.key,
    this.categories,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late MonthFilter _selectedMonthFilter;
  late String? _selectedCategory;
  late DateTime? _customStartDate;
  late DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionsBloc>().state;
    _selectedMonthFilter = state.selectedMonthFilter;
    _selectedCategory = state.selectedCategory;
    _customStartDate = state.customStartDate;
    _customEndDate = state.customEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.filterTransactions),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePeriodSection(l10n),
            const SizedBox(height: AppSizes.lg),
            _buildCategorySection(l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<TransactionsBloc>().add(TransactionsFiltersCleared());
            Navigator.of(context).pop();
          },
          child: Text(l10n.clearAll),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<TransactionsBloc>().add(TransactionsMonthFilterChanged(
                  monthFilter: _selectedMonthFilter,
                  customStartDate: _customStartDate,
                  customEndDate: _customEndDate,
                ));
            context.read<TransactionsBloc>().add(TransactionsCategoryFilterChanged(_selectedCategory));
            Navigator.of(context).pop();
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }

  Widget _buildTimePeriodSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.timePeriod,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<MonthFilter>(
          value: _selectedMonthFilter,
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedMonthFilter = value!;
            });
          },
          items: MonthFilter.values.map((filter) {
            return DropdownMenuItem<MonthFilter>(
              value: filter,
              child: Text(_getMonthFilterLabel(filter, l10n)),
            );
          }).toList(),
        ),
        if (_selectedMonthFilter == MonthFilter.custom) ...[
          const SizedBox(height: AppSizes.md),
          Text(l10n.customDateRange),
          const SizedBox(height: AppSizes.sm),
          _buildCustomDateRange(l10n),
        ],
      ],
    );
  }

  Widget _buildCustomDateRange(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: l10n.startDate,
            date: _customStartDate,
            onDateSelected: (date) {
              setState(() {
                _customStartDate = date;
              });
            },
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(l10n.to),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _buildDatePicker(
            label: l10n.endDate,
            date: _customEndDate,
            onDateSelected: (date) {
              setState(() {
                _customEndDate = date;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Text(
          date != null ? DateFormat('MMM dd, yyyy').format(date) : label,
          style: TextStyle(
            color: date != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: AppSizes.sm),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: Text(l10n.allCategories),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(l10n.allCategories),
            ),
            if (widget.categories != null)
              ...widget.categories!.map((category) => DropdownMenuItem<String>(
                    value: category['name'] as String,
                    child: Text(category['name'] as String),
                  )),
          ],
        ),
      ],
    );
  }

  String _getMonthFilterLabel(MonthFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case MonthFilter.all:
        return l10n.allTime;
      case MonthFilter.thisMonth:
        return l10n.thisMonth;
      case MonthFilter.lastMonth:
        return l10n.lastMonth;
      case MonthFilter.nextMonth:
        return l10n.nextMonth;
      case MonthFilter.custom:
        return l10n.customRange;
    }
  }
}
