import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthStatusChanged>(_onStatusChanged);
    on<AuthLogoutRequested>(_onLogout);

    authManager.addListener(_onAuthManagerChanged);

    // Sync initial auth state
    if (authManager.isLoggedIn) {
      add(const AuthStatusChanged());
    }
  }

  void _onAuthManagerChanged() {
    add(const AuthStatusChanged());
  }

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      isAuthenticated: authManager.isLoggedIn,
      profile: authManager.profile,
    ));
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await authManager.logout();
    emit(const AuthState());
  }

  @override
  Future<void> close() {
    authManager.removeListener(_onAuthManagerChanged);
    return super.close();
  }
}
