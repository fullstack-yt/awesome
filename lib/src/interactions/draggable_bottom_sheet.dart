import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

enum ExpansionState {
  minimized,
  step,
  expanded;
}

class DraggableBottomSheet extends StatefulWidget {
  final Widget child;
  final Widget bar;
  final Widget modal;
  final Color modalColor;
  final SheetController? controller;
  final Function()? onChange;
  final Function(bool value)? onThreshold;
  final double stepLocation;
  const DraggableBottomSheet({
    required this.child,
    required this.bar,
    required this.modal,
    this.modalColor = Colors.white,
    this.stepLocation = 0.4,
    this.onChange,
    this.controller,
    this.onThreshold,
    super.key,
  })  : assert(0.2 <= stepLocation),
        assert(0.8 > stepLocation);

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _maxHeight;
  late double _initialHeight;
  late double _stepHeight;
  late double _height;
  ExpansionState _expansionState = ExpansionState.minimized;

  double get _distance => _maxHeight - _initialHeight;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _height = 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      value: 0,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.controller != null) {
      widget.controller?.animateToExpanded = _animateExpanded;
      widget.controller?.animateToStep = _animateStep;
      widget.controller?.animateToMinimized = _animateMinimized;
      widget.controller?.state = _expansionState;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialHeight = 70 + max(MediaQuery.of(context).padding.bottom, 16);
    _maxHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        _initialHeight -
        8;
    _stepHeight = widget.stepLocation * _maxHeight;
  }

  _onDragUpdate(DragUpdateDetails details) {
    final offset = details.delta.dy;
    setState(() {
      _height -= offset;
      _controller.value = _height / _maxHeight;
      widget.onThreshold?.call(_controller.value > 0.1);
    });
  }

  _onDragEnd(DragEndDetails details) {
    double velocity = details.velocity.pixelsPerSecond.dy;
    if (_height < _stepHeight) {
      if (velocity > 700) {
        _animateMinimized();
      } else if (_height > _stepHeight / 2 || velocity < -700) {
        _animateStep();
      } else {
        _animateMinimized();
      }
    } else {
      if (velocity > 700) {
        _animateStep();
      } else if (_height > _stepHeight + (_maxHeight - _stepHeight) / 2 ||
          velocity < -700) {
        _animateExpanded();
      } else {
        _animateStep();
      }
    }
  }

  _animateExpanded({Duration? duration}) {
    setState(() {
      _height = _maxHeight;
      _expansionState = ExpansionState.expanded;
      _animate(duration: duration);
    });
    widget.onThreshold?.call(true);
  }

  _animateStep({Duration? duration}) {
    setState(() {
      _height = _stepHeight;
      _expansionState = ExpansionState.step;
      _animate(duration: duration);
    });
    widget.onThreshold?.call(true);
  }

  _animateMinimized({Duration? duration}) {
    _height = 0;
    _expansionState = ExpansionState.minimized;
    _animate(duration: duration);
    widget.onThreshold?.call(false);
  }

  _animate({Duration? duration}) {
    _controller.animateTo(
      _height / _maxHeight,
      curve: Curves.easeOut,
      duration: duration,
    );
    if (_expansionState != widget.controller?.state) {
      widget.controller?.state = _expansionState;
      widget.onChange?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              widget.child,
              IgnorePointer(
                ignoring: _animation.value <= _stepHeight / _distance,
                child: GestureDetector(
                  onTap: _animateMinimized,
                  onPanStart: (_) => _animateMinimized(),
                  child: Container(
                    color: Colors.black.withOpacity(
                        ((_animation.value - _stepHeight / _distance) /
                                    (1 - _stepHeight / _distance))
                                .clamp(0, 1) *
                            0.5),
                  ),
                ),
              ),
              Positioned(
                bottom: _initialHeight +
                    _animation.value * _maxHeight -
                    MediaQuery.of(context).size.height,
                child: GestureDetector(
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: widget.modalColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Platform.isIOS ? 16 : 0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 6,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: widget.modal,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }
}

class SheetController {
  late Function({Duration? duration})? _animateToStep;
  late Function({Duration? duration})? _animateToExpanded;
  late Function({Duration? duration})? _animateToMinimized;
  late ExpansionState? _state;

  ExpansionState get state {
    assert(_state != null);
    return _state!;
  }

  Function({Duration? duration}) get animateToStep {
    assert(_animateToStep != null);
    return _animateToStep!;
  }

  Function({Duration? duration}) get animateToExpanded {
    assert(_animateToExpanded != null);
    return _animateToExpanded!;
  }

  Function({Duration? duration}) get animateToMinimized {
    assert(_animateToMinimized != null);
    return _animateToMinimized!;
  }

  set state(ExpansionState state) {
    _state = state;
  }

  set animateToStep(Function({Duration? duration}) animateToStep) {
    _animateToStep = animateToStep;
  }

  set animateToExpanded(Function({Duration? duration}) animateToExpanded) {
    _animateToExpanded = animateToExpanded;
  }

  set animateToMinimized(Function({Duration? duration}) animateToMinimized) {
    _animateToMinimized = animateToMinimized;
  }

  void dispose() {
    _state = null;
    _animateToStep = null;
    _animateToExpanded = null;
    _animateToMinimized = null;
  }
}
