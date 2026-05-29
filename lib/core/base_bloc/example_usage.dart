/// ÖRNEK KULLANIM - BASE BLOC PATTERN
///
/// Bu dosya, BaseCubit ve BaseBlocView'ın nasıl kullanılacağını gösterir.
///
/// =============================================================================
/// ADIM 1: State Sınıfını Oluştur
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/base_bloc/base_cubit.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';
import 'package:flutter_base_kit/core/base_bloc/base_bloc_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// =============================================================================
/// ÖRNEK 1: Login Cubit
/// =============================================================================

// State sınıfı
class LoginState extends BaseState {
  final String email;
  final String password;
  final bool isPasswordVisible;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  // copyWith metodu
  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isPasswordVisible,
    ...super.props,
  ];
}

// Cubit sınıfı
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({super.authManager, super.apiManager}) : super(const LoginState());

  @override
  void onInit() {
    super.onInit();
    debugPrint('LoginCubit initialized');
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('LoginCubit ready');
  }

  void setEmail(String value) {
    safeEmit(state.copyWith(email: value));
    _validateForm();
  }

  void setPassword(String value) {
    safeEmit(state.copyWith(password: value));
    _validateForm();
  }

  void togglePasswordVisibility() {
    safeEmit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _validateForm() {
    final isValid = state.email.isNotEmpty && state.password.length >= 6;
    safeEmit(state.copyWith(isValid: isValid));
  }

  Future<void> login() async {
    if (!state.isValid) return;

    safeEmit(state.copyWith(isLoading: true));

    try {
      // AuthManager kullanımı - Result<T, ApiError> pattern
      final result = await authManager.login(state.email, state.password);

      result.when(
        ok: (_) {
          // Login başarılı
          safeEmit(state.copyWith(isLoading: false, errorMessage: null));
          // Navigate to home
        },
        err: (error) {
          // Login failed
          safeEmit(
            state.copyWith(isLoading: false, errorMessage: error.message),
          );
        },
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Beklenmeyen bir hata oluştu: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    debugPrint('LoginCubit closed');
    return super.close();
  }
}

// View widget'ı
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<LoginCubit, LoginState>(
      create: () => LoginCubit(),
      onInit: (cubit) => debugPrint('View onInit called'),
      onReady: (cubit) => debugPrint('View onReady called'),
      onDispose: (cubit) => debugPrint('View onDispose called'),
      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error message
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),

                // Email field
                TextField(
                  onChanged: context.read<LoginCubit>().setEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  onChanged: context.read<LoginCubit>().setPassword,
                  obscureText: !state.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: context
                          .read<LoginCubit>()
                          .togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isValid && !state.isLoading
                        ? () => context.read<LoginCubit>().login()
                        : null,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// =============================================================================
/// ÖRNEK 2: User Profile Cubit - API Çağrıları
/// =============================================================================

class UserProfileState extends BaseState {
  final String? username;
  final String? email;
  final String? avatarUrl;

  const UserProfileState({
    this.username,
    this.email,
    this.avatarUrl,
    super.isLoading,
    super.errorMessage,
  });

  UserProfileState copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, email, avatarUrl, ...super.props];
}

class UserProfileCubit extends BaseCubit<UserProfileState> {
  UserProfileCubit({super.authManager, super.apiManager})
    : super(const UserProfileState());

  @override
  void onReady() {
    super.onReady();
    // Widget render'dan sonra profile'ı yükle
    loadProfile();
  }

  Future<void> loadProfile() async {
    safeEmit(state.copyWith(isLoading: true));

    try {
      // AuthManager'dan profile'ı al
      final result = await authManager.fetchMe();

      result.when(
        ok: (_) {
          final profile = authManager.profile;
          safeEmit(
            state.copyWith(
              username: profile?.firstName,
              email: profile?.email,
              isLoading: false,
              errorMessage: null,
            ),
          );
        },
        err: (error) {
          safeEmit(
            state.copyWith(isLoading: false, errorMessage: error.message),
          );
        },
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load profile: $e',
        ),
      );
    }
  }

  Future<void> updateUsername(String newUsername) async {
    safeEmit(state.copyWith(isLoading: true));

    try {
      final result = await authManager.updateProfile({
        'firstName': newUsername,
      });

      result.when(
        ok: (_) {
          safeEmit(
            state.copyWith(
              username: newUsername,
              isLoading: false,
              errorMessage: null,
            ),
          );
        },
        err: (error) {
          safeEmit(
            state.copyWith(isLoading: false, errorMessage: error.message),
          );
        },
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile: $e',
        ),
      );
    }
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<UserProfileCubit, UserProfileState>(
      create: () => UserProfileCubit(),
      builder: (context, state, bloc) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${state.username ?? "N/A"}'),
                const SizedBox(height: 8),
                Text('Email: ${state.email ?? "N/A"}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserProfileCubit>().updateUsername('New Name');
                  },
                  child: const Text('Update Username'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// =============================================================================
/// ÖRNEK 3: Active Key Kullanımı
/// =============================================================================

class DetailCubit extends BaseCubit<DetailState> {
  final String itemId;

  DetailCubit(this.itemId, {super.authManager, super.apiManager})
    : super(DetailState(itemId: itemId));

  @override
  void onReady() {
    super.onReady();
    loadDetail();
  }

  Future<void> loadDetail() async {
    // Load detail for itemId
    debugPrint('Loading detail for item: $itemId');
  }
}

class DetailState extends BaseState {
  final String itemId;
  final String? title;

  const DetailState({required this.itemId, this.title, super.isLoading});

  DetailState copyWith({String? title, bool? isLoading}) {
    return DetailState(
      itemId: itemId,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [itemId, title, ...super.props];
}

class DetailScreen extends StatelessWidget {
  final String itemId;

  const DetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<DetailCubit, DetailState>(
      create: () => DetailCubit(itemId),
      activeKey: 'detail-$itemId', // Her item için benzersiz key
      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(title: Text('Detail: ${state.itemId}')),
          body: Center(child: Text('Item: ${state.itemId}')),
        );
      },
    );
  }
}
