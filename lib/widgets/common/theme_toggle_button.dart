import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode 
                ? Icons.light_mode_rounded 
                : Icons.dark_mode_rounded,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: 'Toggle Theme',
        );
      },
    );
  }
}
