import 'package:flutter/material.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onTapCancel;
  final bool long;
  final bool scale;

  const TapScale({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onTapCancel,
    this.long = false,
    this.scale = true,
  }) : super(key: key);

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          if (widget.onLongPress == null) {
            _pressed = false;
          }
        });
      },
      onLongPress: () {
        setState(() {
          _pressed = false;
        });
        widget.onLongPress?.call();
      },
      onLongPressDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onLongPressUp: () {
        widget.onTapCancel?.call();
        setState(() {
          _pressed = false;
        });
      },
      onLongPressEnd: (_) {
        widget.onTapCancel?.call();
        setState(() {
          _pressed = false;
        });
      },
      onLongPressCancel: () {
        widget.onTapCancel?.call();
        setState(() {
          _pressed = false;
        });
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 150) * (widget.long ? 1.5 : 1),
        scale: (_pressed && widget.scale) ? 0.95 : 1,
        child: widget.child,
      ),
    );
  }
}
