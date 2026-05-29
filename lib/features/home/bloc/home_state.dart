import 'package:flutter_base_kit/core/base_bloc/base_state.dart';

/// Listede gösterilecek tek bir öğe modeli.
class HomeItem {
  final String id;
  final String title;
  final String description;

  const HomeItem({
    required this.id,
    required this.title,
    required this.description,
  });

  factory HomeItem.fromJson(Map<String, dynamic> json) => HomeItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
      );
}

/// HomeBloc'un state'i.
///
/// isLoading, isValid, errorMessage → BaseState'den gelir.
/// Bu sayede LoadingOverlay, hata gösterimi gibi ortak davranışlar
/// BaseBlocView tarafından otomatik yönetilir.
class HomeState extends BaseState {
  final List<HomeItem> items;

  const HomeState({
    this.items = const [],
    super.isLoading,
    super.errorMessage,
  });

  HomeState copyWith({
    List<HomeItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      // null geçilirse mevcut değeri koru; açıkça temizlemek için
      // errorMessage: null şeklinde çağır → ?? null = null (temizlenir)
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  HomeState clearError() => HomeState(
        items: items,
        isLoading: isLoading,
        errorMessage: null,
      );

  @override
  List<Object?> get props => [...super.props, items];
}
