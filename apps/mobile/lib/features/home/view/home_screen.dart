import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_kit_auth/flutter_kit_auth.dart';
import 'package:flutter_kit_ui/theme/theme_cubit.dart';
import 'package:flutter_base_kit/core/di/injection.dart';
import 'package:flutter_base_kit/core/domain/entity/user_profile.dart';
import 'package:flutter_base_kit/core/domain/usecase/get_user_profile_usecase.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../../../core/managers/navigation_manager/app_coordinator.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Result<UserProfile, ApiError>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = getIt<GetUserProfileUseCase>().call();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oturumu Kapat'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseBlocView<HomeBloc, HomeState>(
      create: () => HomeBloc(),
      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            leading: Icon(Icons.dashboard_outlined, color: colorScheme.primary),
            actions: [
              IconButton(
                icon: Icon(
                  theme.brightness == Brightness.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                tooltip: 'Tema Değiştir',
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Colors.redAccent),
                onPressed: _logout,
                tooltip: 'Çıkış Yap',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              bloc.add(const HomeRefreshed());
              _loadProfile();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FutureBuilder<Result<UserProfile, ApiError>>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return snapshot.data!.when(
                        ok: (profile) => _buildProfileCard(context, profile),
                        err: (error) => _buildProfileErrorCard(context, error.message),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                _buildShowcasePromoCard(context),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ağdan Gelen Veriler (/home/items)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (state.errorMessage != null && state.items.isEmpty)
                  _buildErrorView(
                    context,
                    state.errorMessage!,
                    () => bloc.add(const HomeFetched()),
                  )
                else if (state.items.isEmpty && !state.isLoading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Veri bulunamadı.')),
                    ),
                  )
                else
                  ...state.items.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.api_outlined, color: colorScheme.primary),
                          ),
                          title: Text(item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.description),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primary,
              child: Text(
                profile.firstName.isNotEmpty
                    ? profile.firstName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz,',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    profile.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profil yüklenemedi: $error',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcasePromoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: AppCoordinator.instance.home.pushShowcase,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROJE MİMARİSİ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monorepo & Clean Architecture Canlandırma',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Katmanlar arası veri akışını ve interceptor loglarını interaktif olarak keşfedin.',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
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
