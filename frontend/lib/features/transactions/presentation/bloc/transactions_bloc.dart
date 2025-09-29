import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(const TransactionsState()) {
    on<TransactionsSearchChanged>(_onSearchChanged);
    on<TransactionsCategoryFilterChanged>(_onCategoryFilterChanged);
    on<TransactionsMonthFilterChanged>(_onMonthFilterChanged);
    on<TransactionsFiltersCleared>(_onFiltersCleared);
    on<TransactionsSearchToggled>(_onSearchToggled);
    on<TransactionsUpdated>(_onTransactionsUpdated);
  }

  void _onSearchChanged(TransactionsSearchChanged event, Emitter<TransactionsState> emit) {
    final newState = state.copyWith(searchQuery: event.query);
    emit(_applyFilters(newState));
  }

  void _onCategoryFilterChanged(TransactionsCategoryFilterChanged event, Emitter<TransactionsState> emit) {
    final newState = state.copyWith(selectedCategory: event.category);
    emit(_applyFilters(newState));
  }

  void _onMonthFilterChanged(TransactionsMonthFilterChanged event, Emitter<TransactionsState> emit) {
    final newState = state.copyWith(
      selectedMonthFilter: event.monthFilter,
      customStartDate: event.customStartDate,
      customEndDate: event.customEndDate,
    );
    emit(_applyFilters(newState));
  }

  void _onFiltersCleared(TransactionsFiltersCleared event, Emitter<TransactionsState> emit) {
    final newState = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
      selectedMonthFilter: MonthFilter.all,
      customStartDate: null,
      customEndDate: null,
    );
    emit(_applyFilters(newState));
  }

  void _onSearchToggled(TransactionsSearchToggled event, Emitter<TransactionsState> emit) {
    emit(state.copyWith(
      showSearch: !state.showSearch,
      searchQuery: state.showSearch ? '' : state.searchQuery,
    ));
  }

  void _onTransactionsUpdated(TransactionsUpdated event, Emitter<TransactionsState> emit) {
    final newState = state.copyWith(allTransactions: event.transactions);
    emit(_applyFilters(newState));
  }

  void updateTransactions(List<TransactionEntity> transactions) {
    add(TransactionsUpdated(transactions));
  }

  TransactionsState _applyFilters(TransactionsState state) {
    var filtered = state.allTransactions;

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.title.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
            transaction.category.toLowerCase().contains(state.searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.category.toLowerCase() == state.selectedCategory!.toLowerCase();
      }).toList();
    }

    // Filter by month
    filtered = _filterByMonth(filtered, state);

    return state.copyWith(filteredTransactions: filtered);
  }

  List<TransactionEntity> _filterByMonth(List<TransactionEntity> transactions, TransactionsState state) {
    if (state.selectedMonthFilter == MonthFilter.all) {
      return transactions;
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (state.selectedMonthFilter) {
      case MonthFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case MonthFilter.lastMonth:
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
        startDate = DateTime(lastMonthYear, lastMonth, 1);
        endDate = DateTime(lastMonthYear, lastMonth + 1, 0, 23, 59, 59);
        break;
      case MonthFilter.nextMonth:
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
        startDate = DateTime(nextMonthYear, nextMonth, 1);
        endDate = DateTime(nextMonthYear, nextMonth + 1, 0, 23, 59, 59);
        break;
      case MonthFilter.custom:
        if (state.customStartDate == null || state.customEndDate == null) {
          return transactions;
        }
        startDate = DateTime(state.customStartDate!.year, state.customStartDate!.month, state.customStartDate!.day);
        endDate = DateTime(state.customEndDate!.year, state.customEndDate!.month, state.customEndDate!.day, 23, 59, 59);
        break;
      default:
        return transactions;
    }

    return transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  String getMonthFilterLabel(MonthFilter filter) {
    switch (filter) {
      case MonthFilter.all:
        return 'All Time';
      case MonthFilter.thisMonth:
        return 'This Month';
      case MonthFilter.lastMonth:
        return 'Last Month';
      case MonthFilter.nextMonth:
        return 'Next Month';
      case MonthFilter.custom:
        return 'Custom Range';
    }
  }

  String getActiveFiltersText() {
    List<String> filters = [];

    if (state.selectedMonthFilter != MonthFilter.all) {
      filters.add(getMonthFilterLabel(state.selectedMonthFilter));
    }

    if (state.selectedCategory != null) {
      filters.add(state.selectedCategory!);
    }

    if (state.searchQuery.isNotEmpty) {
      filters.add('Search: "${state.searchQuery}"');
    }

    return filters.join(' • ');
  }
}
