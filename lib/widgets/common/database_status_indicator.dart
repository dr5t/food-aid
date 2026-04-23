import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DatabaseStatusIndicator extends StatelessWidget {
  const DatabaseStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final dbOnline = context.watch<AuthProvider>().dbOnline;
    final color = dbOnline ? AppColors.neonCyan : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          if (dbOnline)
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseIndicator(color: color, isLive: dbOnline),
          const SizedBox(width: 8),
          Text(
            dbOnline ? 'DATABASE: LIVE' : 'DATABASE: OFFLINE',
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  final bool isLive;
  const _PulseIndicator({required this.color, required this.isLive});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isLive ? 1500 : 400),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLive != widget.isLive) {
      _controller.duration = Duration(milliseconds: widget.isLive ? 1500 : 400);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double opacity = _controller.value;
        // Add flicker effect when offline
        if (!widget.isLive) {
          opacity = (opacity > 0.5) ? 1.0 : 0.2;
        }

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.8 * opacity),
                blurRadius: 8 * opacity,
                spreadRadius: 2 * opacity,
              ),
            ],
          ),
        );
      },
    );
  }
}

