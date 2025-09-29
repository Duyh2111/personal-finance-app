import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/connectivity/connectivity_bloc.dart';
import 'no_internet_banner.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        return Column(
          children: [
            if (showBanner && state is ConnectivityOffline)
              NoInternetBanner(
                onRetry: () {
                  context
                      .read<ConnectivityBloc>()
                      .add(ConnectivityCheckRequested());
                },
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}