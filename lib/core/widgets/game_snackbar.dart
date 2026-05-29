import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/game/game_colors.dart';
import '../theme/game/game_text_styles.dart';

enum GameSnackBarType { info, success, warning, error }

class GameSnackBar {
  GameSnackBar._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    GameSnackBarType type = GameSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (icon, color) = switch (type) {
      GameSnackBarType.info    => (Icons.info_outline,           AppColors.gold),
      GameSnackBarType.success => (Icons.check_circle_outline,   AppColors.success),
      GameSnackBarType.warning => (Icons.warning_amber_outlined, AppColors.eraOrange),
      GameSnackBarType.error   => (Icons.cancel_outlined,        AppColors.danger),
    };

    _current?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 16.h,
        left: 24.w,
        right: 24.w,
        child: Material(
          color: Colors.transparent,
          child: _AnimatedSnackBar(
            title: title,
            message: message,
            icon: icon,
            accentColor: color,
          ),
        ),
      ),
    );

    _current = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String? title;
  final String message;
  final IconData icon;
  final Color accentColor;

  const _AnimatedSnackBar({
    required this.message,
    required this.icon,
    required this.accentColor,
    this.title,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _GameSnackBarContent(
          title: widget.title,
          message: widget.message,
          icon: widget.icon,
          accentColor: widget.accentColor,
        ),
      ),
    );
  }
}

class _GameSnackBarContent extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final Color accentColor;

  const _GameSnackBarContent({
    required this.message,
    required this.icon,
    required this.accentColor,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 3.w, color: accentColor),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Icon(icon, color: accentColor, size: 22.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!.toUpperCase(),
                                style: AppTextStyles.cardHeader.copyWith(
                                  color: accentColor,
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                            Text(
                              message,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
