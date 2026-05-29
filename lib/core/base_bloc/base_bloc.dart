import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';
import 'package:flutter_base_kit/core/base_bloc/lifecycle_bloc.dart';
import 'package:flutter_base_kit/core/di/injection.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager_interface.dart';

/// Base Bloc - tüm bloc'lar bundan türetilmeli
///
/// Lifecycle methodları (opsiyonel - override edilebilir):
/// - onInit: Bloc oluşturulduğunda çağrılır
/// - onReady: Widget render edildikten sonra çağrılır (post-frame)
/// - close: Bloc dispose edildiğinde otomatik çağrılır
///
/// Dependency Injection (opsiyonel):
/// - authManager: AuthManager instance (constructor'dan geçilmezse GetIt'ten alınır)
/// - apiManager: ApiManager instance (constructor'dan geçilmezse GetIt'ten alınır)
/// - Her bloc sadece ihtiyacı olan dependency'leri kullanmalı
///
/// Örnek:
/// ```dart
/// class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
///   final PokemonRepository repo;
///
///   HomeBloc(this.repo) : super(const HomeState()) {
///     // authManager ve apiManager kullanmıyoruz - sorun yok!
///     on<HomeStarted>(_onStarted);
///   }
/// }
/// ```
///
abstract class BaseBloc<E, S extends BaseState> extends Bloc<E, S>
    implements LifecycleBloc {
  final AuthManager authManager;
  final ApiManager apiManager;

  BaseBloc(
    super.initialState, {
    AuthManager? authManager,
    ApiManager? apiManager,
  })  : authManager = authManager ?? getIt<AuthManager>(),
        apiManager = apiManager ?? getIt<ApiManager>() {
    // onReady her zaman post-frame'de tetiklenir.
    // BaseBlocView kullanılsın ya da kullanılmasın garantilidir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) onReady();
    });
  }

  /// Bloc oluşturulduğunda çağrılır (opsiyonel)
  /// Override edilerek initialization logic yazılabilir
  @override
  void onInit() {}

  /// Widget render edildikten sonra çağrılır (opsiyonel, post-frame callback)
  /// Override edilerek API çağrıları gibi async işlemler yapılabilir
  @override
  void onReady() {}

  @override
  Future<void> close() {
    // Cleanup logic buraya eklenebilir
    return super.close();
  }
}
