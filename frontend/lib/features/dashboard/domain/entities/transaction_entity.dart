import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String icon;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
  });

  @override
  List<Object> get props => [id, title, category, amount, date, icon];
}