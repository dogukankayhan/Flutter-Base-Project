import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';
import 'package:flutter_base_kit/core/base_bloc/lifecycle_bloc.dart';
import 'package:flutter_base_kit/core/di/injection.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager_interface.dart';

/// Base Cubit - tüm cubit'ler bundan türetilmeli
///
/// Lifecycle methodları (opsiyonel - override edilebilir):
/// - onInit: Cubit oluşturulduğunda çağrılır
/// - onReady: Widget render edildikten sonra çağrılır (post-frame)
/// - close: Cubit dispose edildiğinde otomatik çağrılır
///
/// Dependency Injection (opsiyonel):
/// - authManager: AuthManager instance (constructor'dan geçilmezse GetIt'ten alınır)
/// - apiManager: ApiManager instance (constructor'dan geçilmezse GetIt'ten alınır)
/// - Her cubit sadece ihtiyacı olan dependency'leri kullanmalı
///
abstract class BaseCubit<T extends BaseState> extends Cubit<T>
    implements LifecycleBloc {
  final AuthManager authManager;
  final ApiManager apiManager;

  BaseCubit(
    super.initialState, {
    AuthManager? authManager,
    ApiManager? apiManager,
  }) : authManager = authManager ?? getIt<AuthManager>(),
       apiManager = apiManager ?? getIt<ApiManager>();

  /// Cubit oluşturulduğunda çağrılır (opsiyonel)
  /// Override edilerek initialization logic yazılabilir
  @override
  void onInit() {}

  /// Widget render edildikten sonra çağrılır (opsiyonel, post-frame callback)
  /// Override edilerek API çağrıları gibi async işlemler yapılabilir
  @override
  void onReady() {}

  /// Safe emit - cubit kapalı değilse emit et
  void safeEmit(T newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    // Cleanup logic buraya eklenebilir
    return super.close();
  }
}
