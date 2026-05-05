import 'package:flutter/material.dart';
import 'hitech_loader.dart';

class ScanningOverlay extends StatelessWidget {
  final String label;
  const ScanningOverlay({super.key, this.label = 'LOADING...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: HitechLoader(
          text: label,
          color: Colors.white,
        ),
      ),
    );
  }
}
