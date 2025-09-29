import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../utils/connectivity_helper.dart';

// Events
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStarted extends ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;

  const ConnectivityChanged(this.result);

  @override
  List<Object> get props => [result];
}

class ConnectivityCheckRequested extends ConnectivityEvent {}

// States
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {
  final ConnectivityResult connectionType;

  const ConnectivityOnline(this.connectionType);

  @override
  List<Object> get props => [connectionType];
}

class ConnectivityOffline extends ConnectivityState {}

// BLoC
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityHelper _connectivityHelper;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ConnectivityBloc({
    ConnectivityHelper? connectivityHelper,
  })  : _connectivityHelper = connectivityHelper ?? ConnectivityHelper(),
        super(ConnectivityInitial()) {
    on<ConnectivityStarted>(_onConnectivityStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<ConnectivityCheckRequested>(_onConnectivityCheckRequested);
  }

  Future<void> _onConnectivityStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    // Check initial connectivity
    final result = await _connectivityHelper.connectivityResult;
    add(ConnectivityChanged(result));

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityHelper.onConnectivityChanged
        .listen((result) => add(ConnectivityChanged(result)));
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    if (event.result == ConnectivityResult.none) {
      emit(ConnectivityOffline());
    } else {
      emit(ConnectivityOnline(event.result));
    }
  }

  Future<void> _onConnectivityCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    final result = await _connectivityHelper.connectivityResult;
    add(ConnectivityChanged(result));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}