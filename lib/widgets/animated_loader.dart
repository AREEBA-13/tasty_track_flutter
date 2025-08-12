import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AnimatedLoader extends StatefulWidget {
  final double size;
  final Color? color;
  const AnimatedLoader({super.key, this.size = 50, this.color});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Icon(
        Icons.local_dining,
        size: widget.size,
        color: widget.color ?? AppColors.primary,
      ),
    );
  }
}
