import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/active_cubit_helper.dart';
import 'package:flutter_base_kit/core/base_bloc/lifecycle_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';
import '../widgets/loading_overlay.dart';

/// Base Bloc View - tüm bloc/cubit view'ler bu widget'ı kullanmalı
///
/// Özellikler:
/// - Bloc/Cubit lifecycle'ını yönetir (onInit, onReady, close)
/// - Active key ile aynı tipten birden fazla ekranı ayırt eder
/// - onInit, onReady, onDispose callback'lerini sağlar
/// - GetIt ile bloc/cubit'leri publish/unpublish eder
/// - Hem BaseBloc hem BaseCubit destekler
///
final class BaseBlocView<C extends LifecycleBloc, S extends BaseState>
    extends StatefulWidget {
  /// Ekranın içeriğini çizen builder
  /// [bloc] parametresi eklendi - artık builder içinde bloc'a direkt erişebilirsiniz
  final Widget Function(BuildContext context, S state, C bloc) builder;

  /// Bloc/Cubit'i oluşturan fonksiyon
  final C Function() create;

  /// Aynı tipten birden fazla ekranı ayırt etmek için opsiyonel active key.
  /// Örn: StoryDetail için storyId, Chat için conversationId...
  final String? activeKey;

  /// Bloc/Cubit lifecycle callback'leri
  final Function(C)? onInit;
  final Function(C)? onReady;
  final Function(C)? onDispose;

  /// build sonrası post-frame çağrı ister misin? (default: true)
  final bool? usePostFrame;

  const BaseBlocView({
    super.key,
    required this.builder,
    required this.create,
    this.activeKey,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.usePostFrame,
  });

  @override
  State<BaseBlocView<C, S>> createState() => _BaseBlocViewState<C, S>();
}


final class _BaseBlocViewState<C extends LifecycleBloc, S extends BaseState>
    extends State<BaseBlocView<C, S>> with WidgetsBindingObserver {
  late final C bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1) Bloc/Cubit'i ekrana özel oluştur
    bloc = widget.create();

    // 2) Aktif bloc olarak yayınla (key'li veya defaultsuz)
    publishActive<C>(bloc, key: widget.activeKey);

    // 3) onInit callback
    bloc.onInit();
    widget.onInit?.call(bloc);

    // 4) onReady: bloc.onReady() BaseBloc constructor'ında otomatik tetiklenir.
    // Burada sadece view katmanına ait kullanıcı callback'i çağrılır.
    final usePostFrame = widget.usePostFrame ?? true;
    if (usePostFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReady?.call(bloc);
      });
    } else {
      widget.onReady?.call(bloc);
    }
  }

  @override
  void dispose() {
    // dispose callback
    widget.onDispose?.call(bloc);

    // 5) Ekran kapanınca aktif bloc yayını kaldır (key'li veya defaultsuz)
    unpublishActive<C>(key: widget.activeKey);

    WidgetsBinding.instance.removeObserver(this);

    // Bloc/Cubit'i kapat
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cast to StateStreamableSource for BlocProvider/BlocBuilder
    final stateStreamable = bloc as StateStreamableSource<S>;

    return BlocProvider<StateStreamableSource<S>>.value(
      value: stateStreamable,
      child: BlocBuilder<StateStreamableSource<S>, S>(
        builder: (context, state) {
          return Stack(
            children: [
              widget.builder(context, state, bloc),
              if (state.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}
