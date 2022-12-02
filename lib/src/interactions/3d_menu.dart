import 'package:flutter/material.dart';

class AnimationOne extends StatefulWidget {
  final Widget menu;
  final Widget child;
  const AnimationOne({
    super.key,
    required this.child,
    required this.menu,
  });

  @override
  State<AnimationOne> createState() => _AnimationOneState();
}

class _AnimationOneState extends State<AnimationOne> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
