import 'package:flutter/material.dart';
import 'package:crackitx/core/theme/app_theme.dart';

class WavyGradientContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final ImageProvider? image;

  const WavyGradientContainer({
    Key? key,
    this.height,
    this.width,
    this.child,
    this.borderRadius,
    this.gradient,
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
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppTheme.primaryGradient,
            ),
          ),
          // Wavy image overlay
          if (image != null)
            Container(
              decoration: BoxDecoration(
                image:  DecorationImage(
                  image: image!,
                  fit: BoxFit.none,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withAlpha(15),
                    BlendMode.screen,
                  ),
                )
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/wavy_bg.png'),
                  fit: BoxFit.none,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          // Foreground child
          if (child != null) child!,
        ],
      ),
    );
  }
} 