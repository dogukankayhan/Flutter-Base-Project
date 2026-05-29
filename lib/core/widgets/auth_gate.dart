import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../managers/auth_manager/auth/bloc/auth_bloc.dart';
import '../managers/auth_manager/auth/bloc/auth_state.dart';

/// Global modal login guard for protected routes.
class AuthGate extends StatefulWidget {
  final String next;
  final Widget child;
  final bool showLoader;
  const AuthGate({super.key, required this.next, required this.child, this.showLoader = true});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _ready = false;
  bool _awaitingLogin = false;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guard());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub?.cancel();
    final bloc = context.read<AuthBloc>();
    _sub = bloc.stream.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onAuthChanged(AuthState state) {
    if (!mounted) return;
    if (state.isAuthenticated) {
      if (!_ready) setState(() => _ready = true);
      _awaitingLogin = false;
    }
  }

  Future<void> _guard() async {
    if (!mounted) return;
    final bloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    if (bloc.state.isAuthenticated) {
      setState(() => _ready = true);
      return;
    }

    final current = router.routerDelegate.currentConfiguration.uri.toString();
    if (current.startsWith('/login')) return;

    if (_awaitingLogin) return;
    _awaitingLogin = true;

    // post-frame navigation
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    await router.push('/login?next=${Uri.encodeComponent(widget.next)}');
    if (!mounted) return;

    if (context.read<AuthBloc>().state.isAuthenticated) {
      if (!_ready) setState(() => _ready = true);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (router.canPop()) router.pop();
      });
      _awaitingLogin = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      if (!widget.showLoader) return const SizedBox.shrink();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
