import 'package:equatable/equatable.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';
import 'transactions_event.dart';

class TransactionsState extends Equatable {
  final String searchQuery;
  final String? selectedCategory;
  final bool showSearch;
  final MonthFilter selectedMonthFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final List<TransactionEntity> allTransactions;
  final List<TransactionEntity> filteredTransactions;

  const TransactionsState({
    this.searchQuery = '',
    this.selectedCategory,
    this.showSearch = false,
    this.selectedMonthFilter = MonthFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.allTransactions = const [],
    this.filteredTransactions = const [],
  });

  TransactionsState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool? showSearch,
    MonthFilter? selectedMonthFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    List<TransactionEntity>? allTransactions,
    List<TransactionEntity>? filteredTransactions,
  }) {
    return TransactionsState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showSearch: showSearch ?? this.showSearch,
      selectedMonthFilter: selectedMonthFilter ?? this.selectedMonthFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
    );
  }

  bool get hasActiveFilters {
    return selectedMonthFilter != MonthFilter.all || selectedCategory != null || searchQuery.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        searchQuery,
        selectedCategory,
        showSearch,
        selectedMonthFilter,
        customStartDate,
        customEndDate,
        allTransactions,
        filteredTransactions,
      ];
}
