import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final List<Widget>? children;
  final Widget? child;

  const AppBackground({super.key, this.children, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          if (child case final child?) child,
          if (children != null) ...children!,
        ],
      ),
    );
  }
}
