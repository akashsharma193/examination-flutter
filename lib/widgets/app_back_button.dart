import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final double? size;

  const AppBackButton({Key? key, this.onTap, this.color, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    return IconButton(
      icon: Icon(
        isIOS ? Icons.chevron_left : Icons.arrow_back,
        color: color ?? Colors.white,
        size: size ?? 28,
      ),
      onPressed: onTap ?? () => Navigator.of(context).maybePop(),
      splashRadius: 24,
      tooltip: 'Back',
    );
  }
} 