import 'package:equatable/equatable.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsSearchChanged extends TransactionsEvent {
  final String query;

  const TransactionsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TransactionsCategoryFilterChanged extends TransactionsEvent {
  final String? category;

  const TransactionsCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class TransactionsMonthFilterChanged extends TransactionsEvent {
  final MonthFilter monthFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const TransactionsMonthFilterChanged({
    required this.monthFilter,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [monthFilter, customStartDate, customEndDate];
}

class TransactionsFiltersCleared extends TransactionsEvent {}

class TransactionsSearchToggled extends TransactionsEvent {}

class TransactionsUpdated extends TransactionsEvent {
  final List<TransactionEntity> transactions;

  const TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

enum MonthFilter {
  all,
  thisMonth,
  lastMonth,
  nextMonth,
  custom,
}
