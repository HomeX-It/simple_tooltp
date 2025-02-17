part of tooltip;

class _BallonTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final TooltipDirection tooltipDirection;
  final bool hide;
  final Function(AnimationStatus)? animationEnd;

  _BallonTransition({
    Key? key,
    required this.child,
    required this.duration,
    required this.tooltipDirection,
    this.hide = false,
    this.animationEnd,
  }) : super(key: key);

  @override
  _BallonTransitionState createState() => _BallonTransitionState();
}

class _BallonTransitionState extends State<_BallonTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      curve: Curves.bounceOut,
      parent: _animationController,
    );
    _rotationAnimation = Tween<double>(begin: pi * .5, end: 0).animate(
      curvedAnimation,
    );
    if (!widget.hide) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _animationController.addStatusListener((status) {
      if ((status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) &&
          widget.animationEnd != null) {
        widget.animationEnd!(status);
      }
    });
  }

  @override
  void didUpdateWidget(_BallonTransition oldWidget) {
    if (widget.hide) {
      _animationController.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _OpacityAnimationWrapper(
      duration: widget.duration,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, _) {
          _BalloonTransformation _ballonTransformation =
              _BalloonTransformation.forAnimationValue(
            _rotationAnimation.value,
            widget.tooltipDirection,
          );
          return Transform(
            child: widget.child,
            alignment: _ballonTransformation.alignment,
            transform: _ballonTransformation.transformation,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _BalloonTransformation {
  final Matrix4 transformation;
  final FractionalOffset alignment;

  _BalloonTransformation({
    required this.transformation,
    required this.alignment,
  });

  static _BalloonTransformation forAnimationValue(
      double value, TooltipDirection tooltipDirection) {
    late Matrix4 transformation;
    late FractionalOffset alignment;
    if (tooltipDirection == TooltipDirection.up) {
      transformation = Matrix4.rotationX(value);
      alignment = FractionalOffset.bottomCenter;
    } else if (tooltipDirection == TooltipDirection.down) {
      transformation = Matrix4.rotationX(value);
      alignment = FractionalOffset.topCenter;
    } else if (tooltipDirection == TooltipDirection.right) {
      transformation = Matrix4.rotationY(value);
      alignment = FractionalOffset.centerLeft;
    } else {
      transformation = Matrix4.rotationY(value);
      alignment = FractionalOffset.centerRight;
    }
    return _BalloonTransformation(
      alignment: alignment,
      transformation: transformation,
    );
  }
}

class _OpacityAnimationWrapper extends StatefulWidget {
  final Duration duration;
  const _OpacityAnimationWrapper({
    Key? key,
    required this.child,
    required this.duration,
  }) : super(key: key);

  final Widget child;

  @override
  __OpacityAnimationWrapperState createState() =>
      __OpacityAnimationWrapperState();
}

class __OpacityAnimationWrapperState extends State<_OpacityAnimationWrapper> {
  double _opacity = 0.38;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          _opacity = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _opacity,
      child: widget.child,
    );
  }
}
