// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: TransactionModel._idFromJson(json['id']),
      title: json['description'] as String,
      category: TransactionModel._categoryFromJson(json['category']),
      amount: TransactionModel._amountFromJson(json['amount']),
      date: DateTime.parse(json['transaction_date'] as String),
      userId: json['user_id'] as int,
      notes: json['notes'] as String?,
      categoryId: json['category_id'] as int?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.title,
      'category': instance.category,
      'amount': instance.amount,
      'transaction_date': instance.date.toIso8601String(),
      'notes': instance.notes,
      'category_id': instance.categoryId,
      'user_id': instance.userId,
    };
