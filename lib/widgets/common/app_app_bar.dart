import 'package:flutter/material.dart';
import '../../config/theme/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBottomBorder;
  final bool centerTitle;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBottomBorder = true,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.titleMedium),
      leading: leading,
      centerTitle: centerTitle,
      actions: [if (actions != null) ...actions!, const SizedBox(width: 8)],
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            )
          : null,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
