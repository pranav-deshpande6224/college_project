import 'package:flutter_riverpod/flutter_riverpod.dart';

class Spinner extends StateNotifier<bool> {
  Spinner() : super(false);
  void isLoading() {
    state = true;
  }
  void isDoneLoading(){
    state = false;
  }
}
final spinnerProvider = StateNotifierProvider<Spinner, bool>((_) => Spinner());
final loginSpinner = StateNotifierProvider<Spinner, bool>((_) => Spinner());
final submitSpinner = StateNotifierProvider<Spinner, bool>((_) => Spinner());
final googleSignInSpinner = StateNotifierProvider<Spinner, bool>((_) => Spinner());
final appleSpinner = StateNotifierProvider<Spinner, bool>((_) => Spinner());


