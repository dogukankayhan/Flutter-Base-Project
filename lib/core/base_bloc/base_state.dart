import 'package:equatable/equatable.dart';

/// Base state sınıfı - tüm cubit state'leri bundan türetilmeli
/// 
/// Immutable state pattern kullanır.
/// Equatable ile performans optimizasyonu sağlar.
abstract class BaseState extends Equatable {
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;

  const BaseState({
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isValid, errorMessage];
}
