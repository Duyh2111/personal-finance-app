import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/balance_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_balance_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../../../core/errors/failures.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class DashboardInitialLoadRequested extends DashboardEvent {}

class DashboardRefreshRequested extends DashboardEvent {}

class DashboardBalanceRequested extends DashboardEvent {}

class DashboardRecentTransactionsRequested extends DashboardEvent {}

class DashboardCreateTransactionRequested extends DashboardEvent {
  final Map<String, dynamic> transactionData;

  const DashboardCreateTransactionRequested(this.transactionData);

  @override
  List<Object> get props => [transactionData];
}

class DashboardCategoriesRequested extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardRefreshing extends DashboardState {
  final BalanceEntity balance;
  final List<TransactionEntity> recentTransactions;

  const DashboardRefreshing({
    required this.balance,
    required this.recentTransactions,
  });

  @override
  List<Object> get props => [balance, recentTransactions];
}

class DashboardLoaded extends DashboardState {
  final BalanceEntity balance;
  final List<TransactionEntity> recentTransactions;
  final List<Map<String, dynamic>>? categories;

  const DashboardLoaded({
    required this.balance,
    required this.recentTransactions,
    this.categories,
  });

  @override
  List<Object?> get props => [balance, recentTransactions, categories];

  DashboardLoaded copyWith({
    BalanceEntity? balance,
    List<TransactionEntity>? recentTransactions,
    List<Map<String, dynamic>>? categories,
  }) {
    return DashboardLoaded(
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      categories: categories ?? this.categories,
    );
  }
}

class DashboardError extends DashboardState {
  final Failure failure;

  const DashboardError(this.failure);

  @override
  List<Object> get props => [failure];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetBalanceUseCase getBalanceUseCase;
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  DashboardBloc({
    required this.getBalanceUseCase,
    required this.getRecentTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.getCategoriesUseCase,
  }) : super(DashboardInitial()) {
    on<DashboardInitialLoadRequested>(_onInitialLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardBalanceRequested>(_onBalanceRequested);
    on<DashboardRecentTransactionsRequested>(_onRecentTransactionsRequested);
    on<DashboardCreateTransactionRequested>(_onCreateTransactionRequested);
    on<DashboardCategoriesRequested>(_onCategoriesRequested);
  }

  Future<void> _onInitialLoadRequested(
    DashboardInitialLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(DashboardRefreshing(
        balance: currentState.balance,
        recentTransactions: currentState.recentTransactions,
      ));
    } else {
      emit(DashboardLoading());
    }
    await _loadDashboardData(emit);
  }

  Future<void> _onBalanceRequested(
    DashboardBalanceRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      final balanceResult = await getBalanceUseCase();
      balanceResult.fold(
        (failure) => emit(DashboardError(failure)),
        (balance) => emit(currentState.copyWith(balance: balance)),
      );
    }
  }

  Future<void> _onRecentTransactionsRequested(
    DashboardRecentTransactionsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      final transactionsResult = await getRecentTransactionsUseCase();
      transactionsResult.fold(
        (failure) => emit(DashboardError(failure)),
        (transactions) => emit(currentState.copyWith(recentTransactions: transactions)),
      );
    }
  }

  Future<void> _onCreateTransactionRequested(
    DashboardCreateTransactionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final result = await createTransactionUseCase(event.transactionData);

      result.fold(
        (failure) {
          // For now, just emit the failure
          emit(DashboardError(failure));
        },
        (transaction) {
          // Transaction created successfully, refresh only recent transactions for better performance
          add(DashboardRecentTransactionsRequested());
          add(DashboardBalanceRequested());
        },
      );
    } catch (e) {
      emit(DashboardError(ServerFailure('Failed to create transaction: ${e.toString()}')));
    }
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      // Load balance, recent transactions, and categories
      final balanceResult = await getBalanceUseCase();
      final transactionsResult = await getRecentTransactionsUseCase();
      final categoriesResult = await getCategoriesUseCase();

      // Handle results
      await balanceResult.fold(
        (failure) async {
          emit(DashboardError(failure));
        },
        (balance) async {
          await transactionsResult.fold(
            (failure) async {
              emit(DashboardError(failure));
            },
            (transactions) async {
              await categoriesResult.fold(
                (failure) async {
                  emit(DashboardError(failure));
                },
                (categories) async {
                  emit(DashboardLoaded(
                    balance: balance,
                    recentTransactions: transactions,
                    categories: categories,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(DashboardError(ServerFailure('An unexpected error occurred: ${e.toString()}')));
    }
  }

  Future<void> _onCategoriesRequested(
    DashboardCategoriesRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;

      final categoriesResult = await getCategoriesUseCase();
      categoriesResult.fold(
        (failure) => emit(DashboardError(failure)),
        (categories) => emit(currentState.copyWith(categories: categories)),
      );
    }
  }
}