import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import '../../../core/managers/navigation_manager/app_coordinator.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<RegisterBloc, RegisterState>(
      create: RegisterBloc.new,
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
                    const _BackButton(),
                    const SizedBox(height: 8),
                    const _Header(),
                    const SizedBox(height: 24),
                    _RegisterForm(state: state, bloc: bloc),
                    const SizedBox(height: 24),
                    const _LoginLink(),
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

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.state, required this.bloc});
  final RegisterState state;
  final RegisterBloc bloc;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Ad',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: widget.state.firstNameError,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => widget.bloc.add(RegisterFirstNameChanged(v)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Soyad',
                      errorText: widget.state.lastNameError,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => widget.bloc.add(RegisterLastNameChanged(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: const Icon(Icons.email_outlined),
                errorText: widget.state.emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (v) => widget.bloc.add(RegisterEmailChanged(v)),
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
              onChanged: (v) => widget.bloc.add(RegisterPasswordChanged(v)),
              onSubmitted: (_) => widget.bloc.add(const RegisterSubmitted()),
            ),
            if (widget.state.errorMessage != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: widget.state.errorMessage!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => widget.bloc.add(const RegisterSubmitted()),
              child: const Text('Hesap Oluştur'),
            ),
          ],
        ),
      ),
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: AppCoordinator.instance.login.show,
        tooltip: 'Giriş Yap\'a dön',
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Text('Kayıt Ol',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Yeni bir profil oluşturun',
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

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Zaten hesabınız var mı? ',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
        TextButton(
          onPressed: AppCoordinator.instance.login.show,
          child: const Text('Giriş Yap'),
        ),
      ],
    );
  }
}
