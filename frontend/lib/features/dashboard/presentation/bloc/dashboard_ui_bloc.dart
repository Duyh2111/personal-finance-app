import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class DashboardUIEvent extends Equatable {
  const DashboardUIEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends DashboardUIEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class TimeFilterChanged extends DashboardUIEvent {
  final String filter;

  const TimeFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

class CategoryFilterChanged extends DashboardUIEvent {
  final String filter;

  const CategoryFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

class StatusFilterChanged extends DashboardUIEvent {
  final String filter;

  const StatusFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

class BillingFilterChanged extends DashboardUIEvent {
  final String filter;

  const BillingFilterChanged(this.filter);

  @override
  List<Object> get props => [filter];
}

class TableOptionsChanged extends DashboardUIEvent {
  final DashboardTableOptions options;

  const TableOptionsChanged(this.options);

  @override
  List<Object> get props => [options];
}

class ClearFilters extends DashboardUIEvent {}

// State
class DashboardUIState extends Equatable {
  final String searchQuery;
  final String timeFilter;
  final String categoryFilter;
  final String statusFilter;
  final String billingFilter;
  final DashboardTableOptions tableOptions;

  const DashboardUIState({
    this.searchQuery = '',
    this.timeFilter = 'All',
    this.categoryFilter = 'All Categories',
    this.statusFilter = 'All Status',
    this.billingFilter = 'All Billing',
    this.tableOptions = const DashboardTableOptions(),
  });

  DashboardUIState copyWith({
    String? searchQuery,
    String? timeFilter,
    String? categoryFilter,
    String? statusFilter,
    String? billingFilter,
    DashboardTableOptions? tableOptions,
  }) {
    return DashboardUIState(
      searchQuery: searchQuery ?? this.searchQuery,
      timeFilter: timeFilter ?? this.timeFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      billingFilter: billingFilter ?? this.billingFilter,
      tableOptions: tableOptions ?? this.tableOptions,
    );
  }

  @override
  List<Object> get props => [
        searchQuery,
        timeFilter,
        categoryFilter,
        statusFilter,
        billingFilter,
        tableOptions,
      ];
}

class DashboardTableOptions extends Equatable {
  final bool showRowNumbers;
  final bool showServiceIcon;
  final bool showCategory;
  final bool showAmount;
  final bool showNextBilling;
  final bool showStatus;
  final bool showActions;
  final String tableSize;
  final String sortBy;
  final String sortOrder;

  const DashboardTableOptions({
    this.showRowNumbers = true,
    this.showServiceIcon = true,
    this.showCategory = true,
    this.showAmount = true,
    this.showNextBilling = true,
    this.showStatus = true,
    this.showActions = true,
    this.tableSize = 'Medium',
    this.sortBy = 'Service Name',
    this.sortOrder = 'Ascending',
  });

  DashboardTableOptions copyWith({
    bool? showRowNumbers,
    bool? showServiceIcon,
    bool? showCategory,
    bool? showAmount,
    bool? showNextBilling,
    bool? showStatus,
    bool? showActions,
    String? tableSize,
    String? sortBy,
    String? sortOrder,
  }) {
    return DashboardTableOptions(
      showRowNumbers: showRowNumbers ?? this.showRowNumbers,
      showServiceIcon: showServiceIcon ?? this.showServiceIcon,
      showCategory: showCategory ?? this.showCategory,
      showAmount: showAmount ?? this.showAmount,
      showNextBilling: showNextBilling ?? this.showNextBilling,
      showStatus: showStatus ?? this.showStatus,
      showActions: showActions ?? this.showActions,
      tableSize: tableSize ?? this.tableSize,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object> get props => [
        showRowNumbers,
        showServiceIcon,
        showCategory,
        showAmount,
        showNextBilling,
        showStatus,
        showActions,
        tableSize,
        sortBy,
        sortOrder,
      ];
}

// BLoC
class DashboardUIBloc extends Bloc<DashboardUIEvent, DashboardUIState> {
  DashboardUIBloc() : super(const DashboardUIState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<TimeFilterChanged>(_onTimeFilterChanged);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<BillingFilterChanged>(_onBillingFilterChanged);
    on<TableOptionsChanged>(_onTableOptionsChanged);
    on<ClearFilters>(_onClearFilters);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onTimeFilterChanged(
    TimeFilterChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(timeFilter: event.filter));
  }

  void _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(categoryFilter: event.filter));
  }

  void _onStatusFilterChanged(
    StatusFilterChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.filter));
  }

  void _onBillingFilterChanged(
    BillingFilterChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(billingFilter: event.filter));
  }

  void _onTableOptionsChanged(
    TableOptionsChanged event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(state.copyWith(tableOptions: event.options));
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<DashboardUIState> emit,
  ) {
    emit(const DashboardUIState());
  }
}