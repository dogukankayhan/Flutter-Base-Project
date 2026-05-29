import 'package:flutter_base_kit/core/base_bloc/base_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

/// HomeBloc — BaseBloc'tan türetilir.
///
/// BaseBloc constructor'ından otomatik olarak şunları alır:
///   • authManager  → `getIt<AuthManager>()`
///   • apiManager   → `getIt<ApiManager>()`
///
/// Bunlar constructor'dan override edilebilir (test için kullanışlı):
///   HomeBloc(authManager: mockAuth, apiManager: mockApi)
class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeFetched>(_onFetched);
    on<HomeRefreshed>(_onRefreshed);
  }

  /// Widget render edildikten sonra otomatik çalışır.
  /// İlk veri yüklemesini burada tetikle — initState değil.
  @override
  void onReady() => add(const HomeFetched());

  Future<void> _onFetched(
    HomeFetched event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _loadItems(emit);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    // Refresh'te mevcut liste kalır, sadece loading gösterilir
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _loadItems(emit);
  }

  Future<void> _loadItems(Emitter<HomeState> emit) async {
    // ─── Gerçek projede: repository ve usecase aracılığıyla yapılır ───────────
    //
    // final result = await _getItemsUseCase();
    // result.when(
    //   ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
    //   err: (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
    // );
    //
    // ─── apiManager ile doğrudan kullanım örneği ──────────────────────────────
    //
    // final response = await apiManager.get<List<dynamic>>(path: '/items');
    // response.when(
    //   ok: (data) => emit(state.copyWith(
    //     isLoading: false,
    //     items: data.map((e) => HomeItem.fromJson(e as Map<String, dynamic>)).toList(),
    //   )),
    //   err: (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
    // );
    //
    // ─── Demo: simüle edilmiş API çağrısı ────────────────────────────────────

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockItems = List.generate(
        10,
        (i) => HomeItem(
          id: 'item_$i',
          title: 'Item ${i + 1}',
          description: 'Item ${i + 1} açıklaması',
        ),
      );

      emit(state.copyWith(isLoading: false, items: mockItems));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
