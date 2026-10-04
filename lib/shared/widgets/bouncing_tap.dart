import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A delightful micro-interaction widget that provides a subtle spring bounce
/// and haptic feedback when tapped.
class BouncingTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptic;
  final HitTestBehavior behavior;

  const BouncingTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncingTap> createState() => _BouncingTapState();
}

class _BouncingTapState extends State<BouncingTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleFactor,
      upperBound: 1.0,
    )..value = 1.0;

    _scaleAnimation = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
      _ctrl.animateTo(
        widget.scaleFactor,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _ctrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
      );
    }
  }

  void _handleTapCancel() {
    _ctrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: (details) {
        _handleTapUp(details);
        widget.onTap?.call();
      },
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
