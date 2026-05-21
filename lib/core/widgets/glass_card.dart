import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.accent,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: ObsidianTheme.surface2,
      borderRadius: BorderRadius.circular(ObsidianTheme.radius),
      border: Border.all(
        color: ObsidianTheme.border,
        width: 1,
      ),
    );

    Widget content = Container(
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          splashColor: (accent ?? ObsidianTheme.accent).withValues(alpha: 0.08),
          highlightColor: (accent ?? ObsidianTheme.accent).withValues(alpha: 0.04),
          child: content,
        ),
      );
    }

    return content;
  }
}
