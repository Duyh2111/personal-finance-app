import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'movie':
        return Icons.movie;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'fastfood':
        return Icons.fastfood;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'money_off':
        return Icons.money_off;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.help_outline;
    }
  }
}