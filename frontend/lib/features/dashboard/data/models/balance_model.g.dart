// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceModel _$BalanceModelFromJson(Map<String, dynamic> json) => BalanceModel(
      totalBalance: (json['balance'] as num).toDouble(),
      income: (json['total_income'] as num).toDouble(),
      expenses: (json['total_expenses'] as num).toDouble(),
    );

Map<String, dynamic> _$BalanceModelToJson(BalanceModel instance) =>
    <String, dynamic>{
      'balance': instance.totalBalance,
      'total_income': instance.income,
      'total_expenses': instance.expenses,
    };
