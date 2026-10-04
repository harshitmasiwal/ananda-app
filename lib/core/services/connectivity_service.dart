import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider exposing whether the device currently has network connectivity.
final isOnlineProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      state = results.any((r) => r != ConnectivityResult.none);
    } catch (_) {}

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (mounted && state != isConnected) {
        state = isConnected;
      }
    });
  }

  /// Manually checks and returns latest connectivity status.
  Future<bool> checkOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (mounted) {
        state = isConnected;
      }
      return isConnected;
    } catch (_) {
      return state;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
