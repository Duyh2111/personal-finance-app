import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/balance_entity.dart';

part 'balance_model.g.dart';

@JsonSerializable()
class BalanceModel extends BalanceEntity {
  @JsonKey(name: 'balance')
  @override
  final double totalBalance;

  @JsonKey(name: 'total_income')
  @override
  final double income;

  @JsonKey(name: 'total_expenses')
  @override
  final double expenses;

  const BalanceModel({
    required this.totalBalance,
    required this.income,
    required this.expenses,
  }) : super(
          totalBalance: totalBalance,
          income: income,
          expenses: expenses,
        );

  factory BalanceModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceModelToJson(this);
}