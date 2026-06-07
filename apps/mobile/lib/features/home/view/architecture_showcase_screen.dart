import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_network/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_base_kit/core/di/injection.dart';
import 'package:flutter_base_kit/core/domain/usecase/get_user_profile_usecase.dart';
import '../../../core/managers/navigation_manager/app_coordinator.dart';

class ArchitectureShowcaseScreen extends StatefulWidget {
  const ArchitectureShowcaseScreen({super.key});

  @override
  State<ArchitectureShowcaseScreen> createState() => _ArchitectureShowcaseScreenState();
}

class _ArchitectureShowcaseScreenState extends State<ArchitectureShowcaseScreen> {
  final List<String> _telemetryLogs = [];
  final ScrollController _logScrollController = ScrollController();
  int _activeStep = -1;
  bool _isSimulating = false;
  Timer? _timer;

  static const _flowSteps = [
    {'title': 'View → BLoC', 'desc': 'Event dispatch: LoginSubmitted'},
    {'title': 'BLoC → UseCase', 'desc': 'LoginUseCase.call()'},
    {'title': 'UseCase → Repository', 'desc': 'AuthRepository.login()'},
    {'title': 'Repository → DataSource', 'desc': 'AuthRemoteDataSource.login()'},
    {'title': 'DataSource → API', 'desc': 'POST /auth/login'},
    {'title': 'API → DTO', 'desc': 'AuthDto.fromJson()'},
    {'title': 'DTO → Entity', 'desc': 'AuthEntity mapping'},
    {'title': 'Entity → State', 'desc': 'emit(AuthAuthenticated)'},
  ];

  @override
  void initState() {
    super.initState();
    LoggingInterceptor.onLog = (msg) {
      if (!mounted) return;
      setState(() => _telemetryLogs.add(msg));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logScrollController.hasClients) {
          _logScrollController.animateTo(
            _logScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    };
  }

  @override
  void dispose() {
    LoggingInterceptor.onLog = null;
    _logScrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _runFlowSimulation() async {
    if (_isSimulating) return;
    setState(() {
      _isSimulating = true;
      _activeStep = -1;
    });

    for (int i = 0; i < _flowSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _activeStep = i);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isSimulating = false;
      _activeStep = -1;
    });
  }

  Future<void> _triggerApiCall() async {
    setState(() => _telemetryLogs.add('[SIM] Triggering GET /user/me...'));
    try {
      final result = await getIt<GetUserProfileUseCase>().call();
      if (!mounted) return;
      result.when(
        ok: (profile) => setState(
            () => _telemetryLogs.add('[SIM] Profile loaded: ${profile.fullName}')),
        err: (e) => setState(
            () => _telemetryLogs.add('[SIM][ERR] ${e.message}')),
      );
    } catch (e) {
      if (mounted) setState(() => _telemetryLogs.add('[SIM][ERR] $e'));
    }
  }

  void _copyLogs() {
    Clipboard.setData(ClipboardData(text: _telemetryLogs.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loglar panoya kopyalandı')),
    );
  }

  void _clearLogs() => setState(() => _telemetryLogs.clear());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mimari Canlandırma'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: AppCoordinator.instance.home.show,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monorepo & Clean Architecture',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Katmanlar arası veri akışını ve HTTP telemetrisini interaktif olarak inceleyin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Flow simulation
          _buildFlowCard(context),
          const SizedBox(height: 16),

          // API trigger
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('HTTP Çağrı Simülasyonu',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _triggerApiCall,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('GET /user/me çağır'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _triggerApiCall,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Token Refresh Simüle Et'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Telemetry logs
          _buildTelemetryLogsCard(context),
        ],
      ),
    );
  }

  Widget _buildFlowCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Clean Architecture Akışı',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.tonal(
                  onPressed: _isSimulating ? null : _runFlowSimulation,
                  child: Text(_isSimulating ? 'Çalışıyor…' : 'Simüle Et'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._flowSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = _activeStep == index;
              final isPast = _activeStep > index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primaryContainer
                      : isPast
                          ? colorScheme.surfaceContainerHighest
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: isActive ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : isPast
                                ? colorScheme.secondary
                                : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isPast
                            ? Icon(Icons.check, size: 14, color: colorScheme.onSecondary)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.bold,
                              color: isActive ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            step['desc']!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryLogsCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 10, height: 10,
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 10, height: 10,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 12),
                const Text('console_telemetry.log',
                    style: TextStyle(
                        color: Colors.white70, fontFamily: 'monospace', fontSize: 12)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_copy_outlined, color: Colors.white60, size: 16),
                  onPressed: _copyLogs,
                  tooltip: 'Kopyala',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white60, size: 16),
                  onPressed: _clearLogs,
                  tooltip: 'Temizle',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 16),
            SizedBox(
              height: 220,
              child: _telemetryLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'Henüz log yok. Simülatörü veya HTTP çağrısını tetikleyin.',
                        style: TextStyle(
                            color: Colors.white30, fontSize: 12, fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      controller: _logScrollController,
                      itemCount: _telemetryLogs.length,
                      itemBuilder: (context, index) {
                        final log = _telemetryLogs[index];
                        final Color logColor;
                        if (log.contains('[HTTP][REQ]')) {
                          logColor = Colors.amberAccent;
                        } else if (log.contains('[HTTP][RES]')) {
                          logColor = Colors.greenAccent;
                        } else if (log.contains('[ERR]')) {
                          logColor = Colors.redAccent;
                        } else if (log.contains('[SIM]')) {
                          logColor = Colors.cyanAccent;
                        } else {
                          logColor = Colors.white70;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                                color: logColor, fontFamily: 'monospace', fontSize: 11),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
