import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 20),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      builder: (context, value, child) {
        final adjustedValue = delay == Duration.zero
            ? value
            : ((value - (delay.inMilliseconds / (duration + delay).inMilliseconds))
                    .clamp(0.0, 1.0) /
                (1.0 -
                    (delay.inMilliseconds /
                        (duration + delay).inMilliseconds)));
        return Opacity(
          opacity: adjustedValue.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - adjustedValue.clamp(0.0, 1.0)),
              offset.dy * (1 - adjustedValue.clamp(0.0, 1.0)),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
