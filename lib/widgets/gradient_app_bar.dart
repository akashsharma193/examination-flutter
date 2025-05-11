import 'package:flutter/material.dart';
import 'package:crackitx/core/theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final IconThemeData? iconTheme;

  const GradientAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.bottom,
    this.iconTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.secondaryGradient,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: elevation,
        title: title,
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        bottom: bottom,
        iconTheme: iconTheme,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
} 