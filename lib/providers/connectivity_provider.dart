import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return conn.maybeWhen(
    data: (results) => results.every((r) => r == ConnectivityResult.none),
    orElse: () => false,
  );
});
