import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';
import 'base_state.dart';

/// Pagination destekli state'ler için base class.
///
/// Her paginated ekranın state'i bundan extend etmeli.
/// [T] liste item'ının tipi (örn: PokemonDetail, ForumPost).
abstract class PaginatedState<T> extends BaseState {
  List<T> get items;
  bool get hasMore;
  int get nextOffset;

  const PaginatedState({super.isLoading, super.isValid, super.errorMessage});
}

/// Base Pagination Events
/// Her paginated bloc bu event'leri kullanmalı
sealed class PaginatedEvent {}

class LoadInitialEvent extends PaginatedEvent {}

class LoadMoreEvent extends PaginatedEvent {}

class RefreshEvent extends PaginatedEvent {}

class RemoveItemAtEvent extends PaginatedEvent {
  final int index;
  RemoveItemAtEvent(this.index);
}

class RemoveItemWhereEvent<T> extends PaginatedEvent {
  final bool Function(T item) test;
  RemoveItemWhereEvent(this.test);
}

/// Pagination logic'ini otomatikleştiren mixin.
///
/// Kullanım:
/// ```dart
/// sealed class HomeEvent {}
/// class HomeStarted extends HomeEvent {}
/// class HomeLoadMore extends HomeEvent {}
/// class HomeRefresh extends HomeEvent {}
/// class HomeRemoveAt extends HomeEvent {
///   final int index;
///   HomeRemoveAt(this.index);
/// }
///
/// class HomeBloc extends BaseBloc<HomeEvent, HomeState>
///     with PaginatedBloc<PokemonDetail, HomeEvent, HomeState> {
///
///   HomeBloc(this.repo) : super(const HomeState()) {
///     on<HomeStarted>((e, emit) => handleLoadInitial(emit));
///     on<HomeLoadMore>((e, emit) => handleLoadMore(emit));
///     on<HomeRefresh>((e, emit) => add(HomeStarted()));
///     on<HomeRemoveAt>((e, emit) => handleRemoveAt(e.index, emit));
///   }
///
///   @override
///   Future<(List<PokemonDetail>, bool, int)> fetchPage(int offset, int size) =>
///       repo.pageWithSize(size, offset);
///
///   @override
///   HomeState paginatedState({...}) => state.copyWith(...);
/// }
/// ```
mixin PaginatedBloc<T, E, S extends PaginatedState<T>> on BaseBloc<E, S> {
  /// İlk sayfa boyutu. Override edilebilir.
  int get firstPageSize => 20;

  /// Sonraki sayfaların boyutu. Override edilebilir.
  int get nextPageSize => 20;

  /// Subclass implement eder — veri kaynağından sayfa çeker.
  Future<(List<T> items, bool hasMore, int nextOffset)> fetchPage(
    int offset,
    int size,
  );

  /// Subclass implement eder — mevcut state'i pagination alanlarıyla günceller.
  S paginatedState({
    List<T>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  });

  bool _pBusy = false;
  int _pLastOffset = -1;

  /// Load initial page helper
  /// Event handler içinde çağrılmalı
  Future<void> handleLoadInitial(Emitter<S> emit) async {
    if (_pBusy) return;
    _pBusy = true;
    // Clear error when starting new request
    // ignore: avoid_print
    print('[PAGINATED] Loading initial page...');
    emit(paginatedState(isLoading: true, clearError: true));
    try {
      final (items, hasMore, next) = await fetchPage(0, firstPageSize);
      // ignore: avoid_print
      print('[PAGINATED] Loaded ${items.length} items');
      emit(
        paginatedState(
          items: items,
          hasMore: hasMore,
          nextOffset: next,
          isLoading: false,
        ),
      );
      _pLastOffset = -1;
    } catch (e) {
      // ignore: avoid_print
      print('[PAGINATED] Error loading: $e');
      _pLastOffset = -1;
      emit(paginatedState(isLoading: false, errorMessage: '$e'));
    } finally {
      _pBusy = false;
    }
  }

  /// Load more pages helper
  /// Event handler içinde çağrılmalı
  Future<void> handleLoadMore(Emitter<S> emit) async {
    if (_pBusy || !state.hasMore) return;
    final currentOffset = state.nextOffset;
    if (_pLastOffset == currentOffset) return;
    _pLastOffset = currentOffset;
    _pBusy = true;
    try {
      final (items, hasMore, next) = await fetchPage(
        currentOffset,
        nextPageSize,
      );
      emit(
        paginatedState(
          items: [...state.items, ...items],
          hasMore: hasMore,
          nextOffset: next,
        ),
      );
    } catch (e) {
      _pLastOffset = -1;
      emit(paginatedState(errorMessage: '$e'));
    } finally {
      _pBusy = false;
    }
  }

  /// Remove item at index helper
  /// Event handler içinde çağrılmalı
  void handleRemoveAt(int index, Emitter<S> emit) {
    final current = state.items;
    if (index < 0 || index >= current.length) return;
    emit(paginatedState(items: [...current]..removeAt(index)));
  }

  /// Remove items matching test helper
  /// Event handler içinde çağrılmalı
  void handleRemoveWhere(bool Function(T item) test, Emitter<S> emit) {
    emit(paginatedState(items: state.items.where((e) => !test(e)).toList()));
  }
}
