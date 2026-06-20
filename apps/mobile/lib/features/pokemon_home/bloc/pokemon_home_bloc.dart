import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/domain/repository/favorites_repository.dart';
import 'package:flutter_base_kit/core/domain/repository/pokemon_repository.dart';
import 'package:flutter_base_kit/core/domain/usecase/filter_pokemon_by_type_usecase.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc.dart';
import 'package:flutter_kit_core/base_bloc/paginated_bloc.dart';
import 'package:flutter_kit_network/core/di/service_locator.dart';
import '../../../core/domain/entity/pokemon_entity.dart';
import '../../../core/domain/usecase/get_pokemon_page_usecase.dart';
import '../../../core/domain/usecase/search_pokemon_usecase.dart';
import 'pokemon_home_state.dart';

/// Pokemon Home Events
sealed class PokemonHomeEvent {}

class PokemonHomeStarted extends PokemonHomeEvent {}

class PokemonHomeLoadMore extends PokemonHomeEvent {}

class PokemonHomeRefresh extends PokemonHomeEvent {}

class PokemonHomeRemoveAt extends PokemonHomeEvent {
  final int index;
  PokemonHomeRemoveAt(this.index);
}

class PokemonHomeRemoveById extends PokemonHomeEvent {
  final int id;
  PokemonHomeRemoveById(this.id);
}

class PokemonHomeSearchQueryChanged extends PokemonHomeEvent {
  final String query;
  PokemonHomeSearchQueryChanged(this.query);
}

class PokemonHomeSearch extends PokemonHomeEvent {
  final String query;
  PokemonHomeSearch(this.query);
}

class PokemonHomeFilterByType extends PokemonHomeEvent {
  final String? type;
  PokemonHomeFilterByType(this.type);
}

class PokemonHomeClearFilters extends PokemonHomeEvent {}

class PokemonHomeScrollPositionChanged extends PokemonHomeEvent {
  final double pixels;
  final double maxScrollExtent;
  PokemonHomeScrollPositionChanged(this.pixels, this.maxScrollExtent);
}

class PokemonHomeToggleFavorite extends PokemonHomeEvent {
  final int pokemonId;
  PokemonHomeToggleFavorite(this.pokemonId);
}

class PokemonHomeFavoritesUpdated extends PokemonHomeEvent {
  final Set<int> favoriteIds;
  PokemonHomeFavoritesUpdated(this.favoriteIds);
}

/// Pokemon Home Bloc - Event-driven architecture
class PokemonHomeBloc extends BaseBloc<PokemonHomeEvent, PokemonHomeState>
    with PaginatedBloc<Pokemon, PokemonHomeEvent, PokemonHomeState> {
  final GetPokemonPageUseCase _getPokemonPageUseCase;
  final FilterPokemonByTypeUseCase _filterPokemonByTypeUseCase;
  final SearchPokemonUseCase _searchPokemonUseCase;
  final FavoritesRepository favoritesRepo;
  StreamSubscription? _favoritesSubscription;

  // UI Controllers
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Search debounce
  Timer? _searchDebounceTimer;
  static const _searchDebounceDuration = Duration(milliseconds: 500);

  // Scroll throttle
  DateTime? _lastScrollLoadTime;
  static const _scrollThrottleDuration = Duration(milliseconds: 300);

  PokemonHomeBloc.create()
    : this(
        GetPokemonPageUseCase(getIt<PokemonRepository>()),
        FilterPokemonByTypeUseCase(getIt<PokemonRepository>()),
        SearchPokemonUseCase(getIt<PokemonRepository>()),
        getIt<FavoritesRepository>(),
      );

  PokemonHomeBloc(
    this._getPokemonPageUseCase,
    this._filterPokemonByTypeUseCase,
    this._searchPokemonUseCase,
    this.favoritesRepo,
  ) : super(const PokemonHomeState()) {
    _favoritesSubscription = favoritesRepo.favoriteIdsStream.listen((ids) {
      add(PokemonHomeFavoritesUpdated(ids));
    });

    on<PokemonHomeFavoritesUpdated>((event, emit) {
      emit(state.copyWith(favoriteIds: event.favoriteIds));
    });
    // Setup pagination event handlers
    on<PokemonHomeStarted>((event, emit) async {
      // Load initial data immediately
      await handleLoadInitial(emit);
    });

    on<PokemonHomeLoadMore>((event, emit) => handleLoadMore(emit));

    on<PokemonHomeRefresh>((event, emit) => add(PokemonHomeStarted()));

    on<PokemonHomeRemoveAt>((event, emit) => handleRemoveAt(event.index, emit));

    on<PokemonHomeRemoveById>((event, emit) {
      handleRemoveWhere((item) => item.id == event.id, emit);
    });

    on<PokemonHomeSearch>((event, emit) async {
      final query = event.query.trim();
      emit(
        state.copyWith(
          searchQuery: query.isEmpty ? null : query,
          clearSearch: query.isEmpty,
          selectedType: null, // Clear type filter when searching
          clearFilter: true,
          items: [],
        ),
      );
      await handleLoadInitial(emit);
      _resetScroll();
    });

    on<PokemonHomeFilterByType>((event, emit) async {
      final type = (event.type == state.selectedType) ? null : event.type;
      emit(
        state.copyWith(
          selectedType: type,
          searchQuery: null, // Clear search when filtering
          items: [],
        ),
      );
      await handleLoadInitial(emit);
      _resetScroll();
    });

    on<PokemonHomeClearFilters>((event, emit) {
      emit(
        state.copyWith(
          searchQuery: null,
          selectedType: null,
          clearSearch: true,
          clearFilter: true,
        ),
      );
      add(PokemonHomeStarted());
    });

    on<PokemonHomeSearchQueryChanged>((event, emit) {
      _searchDebounceTimer?.cancel();
      if (event.query.trim().isEmpty) {
        add(PokemonHomeSearch(''));
      } else {
        _searchDebounceTimer = Timer(_searchDebounceDuration, () {
          add(PokemonHomeSearch(event.query));
        });
      }
    });

    on<PokemonHomeScrollPositionChanged>((event, emit) {
      final threshold = event.maxScrollExtent * 0.7;
      if (event.pixels >= threshold) {
        final now = DateTime.now();
        if (_lastScrollLoadTime == null ||
            now.difference(_lastScrollLoadTime!) > _scrollThrottleDuration) {
          if (state.hasMore && !state.isLoading) {
            _lastScrollLoadTime = now;
            add(PokemonHomeLoadMore());
          }
        }
      }
    });

    on<PokemonHomeToggleFavorite>((event, emit) async {
      await favoritesRepo.toggleFavorite(event.pokemonId);
    });
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void _resetScroll() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    scrollController.dispose();
    searchController.dispose();
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  @override
  Future<(List<Pokemon>, bool, int)> fetchPage(int offset, int size) {
    if (state.selectedType != null) {
      return _filterPokemonByTypeUseCase(
        type: state.selectedType!,
        size: size,
        offset: offset,
      );
    }
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      return _searchPokemonUseCase(
        query: state.searchQuery!,
        size: size,
        offset: offset,
      );
    }
    return _getPokemonPageUseCase(size: size, offset: offset);
  }

  @override
  PokemonHomeState paginatedState({
    List<Pokemon>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => state.copyWith(
    items: items,
    hasMore: hasMore,
    nextOffset: nextOffset,
    isLoading: isLoading,
    errorMessage: errorMessage,
    clearError: clearError,
  );
}
