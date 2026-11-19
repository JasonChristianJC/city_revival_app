import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SacredCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final bool hasGoldBorder;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const SacredCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.hasGoldBorder = true,
    this.borderRadius = 16.0,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCard : Colors.white;

    final defaultBorder = hasGoldBorder
        ? Border.all(
            color: AppColors.divineGold.withOpacity(isDark ? 0.35 : 0.25),
            width: 1.2,
          )
        : null;

    final defaultShadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.4)
            : AppColors.primaryBurgundyDark.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? defaultBorder,
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: child,
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
