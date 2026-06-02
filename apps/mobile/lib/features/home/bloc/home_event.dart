import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ilk açıldığında veriyi yükler (onReady içinden tetiklenir).
class HomeFetched extends HomeEvent {
  const HomeFetched();
}

/// Kullanıcı pull-to-refresh yaptığında tetiklenir.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
