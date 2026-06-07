import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import '../../../core/managers/navigation_manager/app_coordinator.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<LoginBloc, LoginState>(
      create: LoginBloc.new,
      builder: (context, state, bloc) => Scaffold(
        body: _Background(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 32),
                    _LoginForm(state: state, bloc: bloc),
                    const SizedBox(height: 24),
                    const _OrDivider(),
                    const SizedBox(height: 16),
                    const _SocialButtons(),
                    const SizedBox(height: 24),
                    const _RegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Form — controller lifecycle ──────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.state, required this.bloc});
  final LoginState state;
  final LoginBloc bloc;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void didUpdateWidget(_LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emailCtrl.text != widget.state.email) _emailCtrl.text = widget.state.email;
    if (_passwordCtrl.text != widget.state.password) _passwordCtrl.text = widget.state.password;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Giriş Yap',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'ornek@posta.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: widget.state.emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (v) => widget.bloc.add(LoginEmailChanged(v)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: widget.state.passwordError,
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (v) => widget.bloc.add(LoginPasswordChanged(v)),
                  onSubmitted: (_) => widget.bloc.add(const LoginSubmitted()),
                ),
                if (widget.state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(message: widget.state.errorMessage!),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => widget.bloc.add(const LoginSubmitted()),
                  child: const Text('Giriş Yap'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => widget.bloc.add(const LoginDemoFillRequested()),
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Demo Hesabı Doldur'),
        ),
      ],
    );
  }
}

// ─── Stateless sub-widgets ─────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surface, cs.primaryContainer.withValues(alpha: 0.12), cs.surface],
        ),
      ),
      child: child,
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Icon(Icons.blur_on_rounded, size: 64, color: cs.primary),
        const SizedBox(height: 12),
        Text('Base Project',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Clean Architecture · Monorepo',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: cs.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('veya',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata, size: 32),
            tooltip: 'Google ile Giriş'),
        const SizedBox(width: 16),
        IconButton.outlined(
            onPressed: () {},
            icon: const Icon(Icons.apple, size: 32),
            tooltip: 'Apple ile Giriş'),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hesabınız yok mu? ',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
        TextButton(
          onPressed: AppCoordinator.instance.register.show,
          child: const Text('Kayıt Ol'),
        ),
      ],
    );
  }
}
