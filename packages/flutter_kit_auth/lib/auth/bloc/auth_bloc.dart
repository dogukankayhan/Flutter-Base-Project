import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc.dart';
import '../manager/auth_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  final AuthManager _authManager;

  AuthBloc(this._authManager) : super(const AuthState()) {
    on<AuthStatusChanged>(_onStatusChanged);
    on<AuthLogoutRequested>(_onLogout);

    _authManager.addListener(_onAuthManagerChanged);

    if (_authManager.isLoggedIn) {
      add(const AuthStatusChanged());
    }
  }

  void _onAuthManagerChanged() => add(const AuthStatusChanged());

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      isAuthenticated: _authManager.isLoggedIn,
      profile: _authManager.profile,
    ));
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _authManager.logout();
    emit(const AuthState());
  }

  @override
  Future<void> close() {
    _authManager.removeListener(_onAuthManagerChanged);
    return super.close();
  }
}
