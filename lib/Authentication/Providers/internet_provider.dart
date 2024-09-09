import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final internetConnectionProvider = StreamProvider<bool>((ref) {
  return InternetConnectionChecker().onStatusChange.map((status) {
    return status == InternetConnectionStatus.connected;
  });
});