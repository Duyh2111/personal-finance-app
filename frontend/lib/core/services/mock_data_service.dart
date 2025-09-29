import '../../features/dashboard/domain/entities/balance_entity.dart';
import '../../features/dashboard/domain/entities/transaction_entity.dart';

abstract class MockDataService {
  static BalanceEntity getBalanceData() {
    return const BalanceEntity(
      totalBalance: 12450.50,
      income: 8200.00,
      expenses: 3150.25,
    );
  }

  static List<TransactionEntity> getRecentTransactions() {
    return [
      TransactionEntity(
        id: '1',
        title: 'Grocery Shopping',
        category: 'Food & Dining',
        amount: -85.50,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        icon: 'shopping_cart',
      ),
      TransactionEntity(
        id: '2',
        title: 'Salary Deposit',
        category: 'Income',
        amount: 3500.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        icon: 'account_balance_wallet',
      ),
      TransactionEntity(
        id: '3',
        title: 'Netflix Subscription',
        category: 'Entertainment',
        amount: -15.99,
        date: DateTime.now().subtract(const Duration(days: 2)),
        icon: 'movie',
      ),
      TransactionEntity(
        id: '4',
        title: 'Coffee',
        category: 'Food & Dining',
        amount: -4.75,
        date: DateTime.now().subtract(const Duration(days: 3)),
        icon: 'local_cafe',
      ),
    ];
  }
}