import 'package:equatable/equatable.dart';

class BalanceEntity extends Equatable {
  final double totalBalance;
  final double income;
  final double expenses;

  const BalanceEntity({
    required this.totalBalance,
    required this.income,
    required this.expenses,
  });

  @override
  List<Object> get props => [totalBalance, income, expenses];
}