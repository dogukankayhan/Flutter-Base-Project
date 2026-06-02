import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_state.dart';
import 'lifecycle_bloc.dart';

/// Base Bloc - tüm bloc'lar bundan türetilmeli.
///
/// authManager / apiManager burada tutulmaz — paket döngüsünü önlemek için
/// her bloc ihtiyacı olan bağımlılığı kendi constructor'ından alır.
///
/// Örnek:
/// ```dart
/// class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
///   final HomeRepository repo;
///   HomeBloc(this.repo) : super(const HomeState()) {
///     on<HomeStarted>(_onStarted);
///   }
/// }
/// ```
abstract class BaseBloc<E, S extends BaseState> extends Bloc<E, S>
    implements LifecycleBloc {
  BaseBloc(super.initialState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) onReady();
    });
  }

  @override
  void onInit() {}

  @override
  void onReady() {}
}
