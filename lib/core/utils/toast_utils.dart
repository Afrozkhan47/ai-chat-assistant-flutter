import 'package:flutter/material.dart';

/// Centered fade + scale success feedback. Auto-dismisses after 1.5s.
void showSuccessToast(
  BuildContext context, {
  String message = 'Settings saved',
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _CenterToast(
      message: message,
      icon: Icons.check_circle_outline,
      isError: false,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

void showErrorToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _CenterToast(
      message: message,
      icon: Icons.error_outline,
      isError: true,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _CenterToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final bool isError;
  final VoidCallback onDismiss;

  const _CenterToast({
    required this.message,
    required this.icon,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(_fade);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = widget.isError ? colorScheme.error : colorScheme.primary;

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.95,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: accent, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
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
