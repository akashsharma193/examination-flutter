import 'package:flutter/material.dart';
import 'package:crackitx/core/theme/app_theme.dart';

class WavyGradientBackground extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final BorderRadius? borderRadius;
  // final Color color;
  final ImageProvider? image;

  const WavyGradientBackground({
    Key? key,
    this.height,
    this.width,
    this.child,
    this.borderRadius,
    // required this.color,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Tiled, low-opacity background image (customizable)

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                image: DecorationImage(
                  image: AssetImage('assets/wavy_bg.png'),
                  fit: BoxFit.none,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withAlpha((0.06*255).floor()),
                    BlendMode.srcIn,
                  ),
                )),
          ),
          // Foreground child
          if (child != null) child!,
        ],
      ),
    );
  }
}
