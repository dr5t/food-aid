import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/theme/app_spacing.dart';
import '../../config/constants.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return MouseRegion(
      onEnter: isWeb ? (_) => setState(() => _isHovering = true) : null,
      onExit: isWeb ? (_) => setState(() => _isHovering = false) : null,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        curve: Curves.easeOut,
        child: Card(
          elevation: _isHovering
              ? AppConstants.cardHoverElevation
              : AppSpacing.elevationSm,
          color: widget.color,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: widget.padding ?? AppSpacing.cardPadding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
