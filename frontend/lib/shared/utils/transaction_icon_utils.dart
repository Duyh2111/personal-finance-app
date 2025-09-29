import 'package:flutter/material.dart';

class TransactionIconUtils {
  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'utilities':
        return Icons.home;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'income':
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'investment':
        return Icons.trending_up;
      case 'bills & utilities':
        return Icons.receipt;
      case 'gas & fuel':
        return Icons.local_gas_station;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'clothing':
        return Icons.checkroom;
      case 'insurance':
        return Icons.security;
      case 'travel':
        return Icons.flight;
      case 'gifts & donations':
        return Icons.card_giftcard;
      case 'personal care':
        return Icons.spa;
      case 'fitness & sports':
        return Icons.fitness_center;
      case 'books & magazines':
        return Icons.menu_book;
      case 'electronics':
        return Icons.devices;
      case 'home improvement':
        return Icons.home_repair_service;
      case 'pet care':
        return Icons.pets;
      case 'taxes':
        return Icons.account_balance;
      case 'interest':
        return Icons.percent;
      case 'bonus':
        return Icons.monetization_on;
      case 'refund':
        return Icons.money_off;
      default:
        return Icons.payment;
    }
  }

  static Color getColorForCategory(String category, BuildContext context) {
    final String lowerCategory = category.toLowerCase();

    // Income categories
    if (_isIncomeCategory(lowerCategory)) {
      return Colors.green;
    }

    // Essential expense categories
    if (_isEssentialExpense(lowerCategory)) {
      return Colors.orange;
    }

    // Entertainment/discretionary categories
    if (_isDiscretionaryExpense(lowerCategory)) {
      return Colors.purple;
    }

    // Default expense color
    return Colors.red;
  }

  static bool _isIncomeCategory(String category) {
    return [
      'income',
      'salary',
      'freelance',
      'investment',
      'bonus',
      'interest',
      'refund',
    ].contains(category);
  }

  static bool _isEssentialExpense(String category) {
    return [
      'utilities',
      'healthcare',
      'insurance',
      'groceries',
      'gas & fuel',
      'bills & utilities',
      'taxes',
    ].contains(category);
  }

  static bool _isDiscretionaryExpense(String category) {
    return [
      'entertainment',
      'shopping',
      'travel',
      'fitness & sports',
      'books & magazines',
      'electronics',
      'gifts & donations',
      'personal care',
    ].contains(category);
  }
}