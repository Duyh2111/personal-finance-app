import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends TransactionEntity {
  @JsonKey(fromJson: _idFromJson)
  @override
  final String id;

  static String _idFromJson(dynamic id) => id.toString();

  @JsonKey(name: 'description')
  @override
  final String title;

  @JsonKey(name: 'category', fromJson: _categoryFromJson)
  @override
  final String category;

  @JsonKey(fromJson: _amountFromJson)
  @override
  final double amount;

  @JsonKey(name: 'transaction_date')
  @override
  final DateTime date;

  final String? notes;

  @JsonKey(name: 'category_id')
  final int? categoryId;

  @JsonKey(name: 'user_id')
  final int userId;

  static String _categoryFromJson(dynamic categoryData) {
    if (categoryData is Map<String, dynamic>) {
      return categoryData['name'] as String? ?? 'Unknown';
    } else if (categoryData is String) {
      return categoryData;
    }
    return 'Unknown';
  }

  static double _amountFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    throw Exception("Invalid amount format: $value");
  }

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.userId,
    this.notes,
    this.categoryId,
  }) : super(
          id: id,
          title: title,
          category: category,
          amount: amount,
          date: date,
          icon: 'account_balance_wallet',
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  String get iconName {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return amount < 0 ? 'restaurant' : 'fastfood';
      case 'entertainment':
        return 'movie';
      case 'shopping':
        return 'shopping_cart';
      case 'income':
      case 'salary':
        return 'account_balance_wallet';
      case 'transportation':
        return 'directions_car';
      case 'utilities':
        return 'home';
      default:
        return amount < 0 ? 'money_off' : 'attach_money';
    }
  }
}
