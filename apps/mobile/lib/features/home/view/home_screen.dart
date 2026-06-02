import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// HomeScreen — BaseBlocView kullanım örneği.
///
/// BaseBlocView şunları otomatik yönetir:
///   • Bloc'un oluşturulması ve dispose edilmesi
///   • state.isLoading → LoadingOverlay gösterimi
///   • onInit / onReady / onDispose lifecycle callback'leri
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<HomeBloc, HomeState>(
      // Bloc burada oluşturulur — DI'dan alınmaz çünkü
      // bu bloc'un ömrü sadece bu ekranla sınırlıdır.
      create: () => HomeBloc(),

      // onReady içinde HomeFetched event'i zaten gönderiliyor,
      // ekstra bir şey yapmak gerekirse buraya eklenebilir.
      onInit: (_) {},
      onDispose: (_) {},

      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(const HomeRefreshed()),
              ),
            ],
          ),
          body: _Body(state: state, bloc: bloc),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.bloc});

  final HomeState state;
  final HomeBloc bloc;

  @override
  Widget build(BuildContext context) {
    // Hata durumu
    if (state.errorMessage != null && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => bloc.add(const HomeFetched()),
      );
    }

    // Boş liste
    if (!state.isLoading && state.items.isEmpty) {
      return const Center(child: Text('Henüz içerik yok.'));
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () async => bloc.add(const HomeRefreshed()),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _ItemCard(item: item);
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final HomeItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(item.id.split('_').last)),
        title: Text(item.title),
        subtitle: Text(item.description),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
