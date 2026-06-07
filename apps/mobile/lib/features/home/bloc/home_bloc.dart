import 'package:flutter_kit_core/base_bloc/base_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeFetched>(_onFetched);
    on<HomeRefreshed>(_onRefreshed);
  }

  @override
  void onReady() => add(const HomeFetched());

  Future<void> _onFetched(HomeFetched event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _loadItems(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _loadItems(emit);
  }

  Future<void> _loadItems(Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: false));
  }
}
