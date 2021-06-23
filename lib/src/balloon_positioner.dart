part of tooltip;

class _BallonPositioner extends StatefulWidget {
  final BuildContext context;
  final TooltipDirection tooltipDirection;
  final double arrowTipDistance;
  final double arrowLength;
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  final double outsidePadding;
  final LayerLink link;

  const _BallonPositioner({
    Key? key,
    required this.tooltipDirection,
    required this.arrowTipDistance,
    required this.arrowLength,
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
    required this.minWidth,
    required this.minHeight,
    required this.outsidePadding,
    required this.link,
    required this.context,
  }) : super(key: key);

  @override
  _BallonPositionerState createState() => _BallonPositionerState();
}

class _BallonPositionerState extends State<_BallonPositioner> {
  GlobalKey _ballonKey = GlobalKey();
  Size? _ballonSize;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_BallonPositioner oldWidget) {
    if (widget.tooltipDirection != oldWidget.tooltipDirection) {
      // invalidate ballon size to perform recalculation
      _ballonSize = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext _) {
    RenderBox renderBox = widget.context.findRenderObject() as RenderBox;
    if (!renderBox.attached) {
      return Container();
    }
    final cOverlay = Overlay.of(widget.context)!;
    if (!cOverlay.mounted) {
      return Container();
    }
    final RenderBox? overlay =
        cOverlay.context.findRenderObject() as RenderBox?;

    if (overlay == null || renderBox.hasSize == false) {
      return Container();
    }

    late Offset tipTarget;

    final Offset zeroOffset = Offset.zero;
    try {
      if (widget.tooltipDirection == TooltipDirection.up) {
        tipTarget = renderBox.size.topCenter(zeroOffset);
      } else if (widget.tooltipDirection == TooltipDirection.down) {
        tipTarget = renderBox.size.bottomCenter(zeroOffset);
      } else if (widget.tooltipDirection == TooltipDirection.right) {
        tipTarget = renderBox.size.centerRight(zeroOffset);
      } else if (widget.tooltipDirection == TooltipDirection.left) {
        tipTarget = renderBox.size.centerLeft(zeroOffset);
      }
    } catch (e) {
      return Container();
    }

    final globalTipTarget = renderBox.localToGlobal(
      tipTarget,
      ancestor: overlay,
    );

    final balloon = CustomSingleChildLayout(
      delegate: _PopupBallonLayoutDelegate(
        arrowLength: widget.arrowLength,
        arrowTipDistance: widget.arrowTipDistance,
        maxHeight: widget.maxHeight,
        maxWidth: widget.maxWidth,
        minHeight: widget.minHeight,
        minWidth: widget.minWidth,
        tooltipDirection: widget.tooltipDirection,
        tipTarget: globalTipTarget,
        outsidePadding: widget.outsidePadding,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: <Widget>[
          Positioned(
            child: Container(
              key: _ballonKey,
              child: widget.child,
            ),
          ),
        ],
      ),
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final ballonContext = _ballonKey.currentContext;
      if (ballonContext != null) {
        final ballonSize = ballonContext.size!;
        final wasNull = _ballonSize == null;
        _ballonSize = ballonSize;

        if (wasNull) {
          setState(() {});
        }
      }
    });

    final offset = getPositionForChild(_ballonSize, overlay, globalTipTarget);

    return Stack(
      children: <Widget>[
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          offset: tipTarget.translate(offset.dx, offset.dy), //
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.loose,
            children: <Widget>[
              Positioned(
                child: Transform.translate(
                  offset: Offset.zero,
                  child: Container(
                    alignment: AlignmentDirectional.bottomStart,
                    child: balloon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Offset getPositionForChild(
    Size? childSize,
    RenderBox overlay,
    Offset globalTipTarget,
  ) {
    if (childSize == null) {
      return Offset.zero;
    }
    Offset ballonOffset;
    final double halfH = childSize.height / 2;
    final double halfW = childSize.width / 2;
    Offset centerPosition = Offset(-halfW, -halfH);
    if (widget.tooltipDirection == TooltipDirection.up) {
      final double yOffset =
          -halfH - widget.arrowLength - widget.arrowTipDistance;
      ballonOffset = centerPosition.translate(0, yOffset);
      ballonOffset = rightBoundingOffset(
        overlay,
        globalTipTarget,
        ballonOffset,
        childSize,
      );
      ballonOffset = leftBoundingOffset(
        globalTipTarget,
        ballonOffset,
      );
    } else if (widget.tooltipDirection == TooltipDirection.down) {
      final double yOffset =
          halfH + widget.arrowLength + widget.arrowTipDistance;
      ballonOffset = centerPosition.translate(0, yOffset);
      ballonOffset = rightBoundingOffset(
        overlay,
        globalTipTarget,
        ballonOffset,
        childSize,
      );
      ballonOffset = leftBoundingOffset(
        globalTipTarget,
        ballonOffset,
      );
    } else if (widget.tooltipDirection == TooltipDirection.right) {
      final double xOffset =
          halfW + widget.arrowLength + widget.arrowTipDistance;
      ballonOffset = centerPosition.translate(xOffset, 0);
      ballonOffset = rightBoundingOffset(
        overlay,
        globalTipTarget,
        ballonOffset,
        childSize,
      );
    } else if (widget.tooltipDirection == TooltipDirection.left) {
      final double xOffset =
          -halfW - widget.arrowLength - widget.arrowTipDistance;
      ballonOffset = centerPosition.translate(xOffset, 0);
      ballonOffset = leftBoundingOffset(
        globalTipTarget,
        ballonOffset,
      );
    } else {
      ballonOffset = centerPosition;
    }
    return ballonOffset;
  }

  Offset leftBoundingOffset(
    Offset globalTipTarget,
    Offset ballonOffset,
  ) {
    final minXOffset = 0;
    final globalBallonLeftBoundingOffset = globalTipTarget.dx + ballonOffset.dx;
    if (globalBallonLeftBoundingOffset < minXOffset) {
      ballonOffset = ballonOffset.translate(
        minXOffset - globalBallonLeftBoundingOffset + widget.outsidePadding,
        0,
      );
    }
    return ballonOffset;
  }

  Offset rightBoundingOffset(
    RenderBox overlay,
    Offset globalTipTarget,
    Offset ballonOffset,
    Size childSize,
  ) {
    final maxXOffset = overlay.size.width;
    final globalBallonRightBoundingOffset =
        globalTipTarget.dx + ballonOffset.dx + childSize.width;
    if (globalBallonRightBoundingOffset > maxXOffset) {
      ballonOffset = ballonOffset.translate(
        maxXOffset - globalBallonRightBoundingOffset - widget.outsidePadding,
        0,
      );
    }
    return ballonOffset;
  }
}

class _PopupBallonLayoutDelegate extends SingleChildLayoutDelegate {
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  final TooltipDirection tooltipDirection;
  final double arrowTipDistance;
  final double arrowLength;
  final Offset tipTarget;
  final double outsidePadding;

  _PopupBallonLayoutDelegate({
    required this.maxWidth,
    required this.maxHeight,
    required this.minWidth,
    required this.minHeight,
    required this.tooltipDirection,
    required this.arrowLength,
    required this.arrowTipDistance,
    required this.tipTarget,
    required this.outsidePadding,
  });

  @override
  bool shouldRelayout(_PopupBallonLayoutDelegate oldDelegate) {
    return oldDelegate.tipTarget.dx != tipTarget.dx ||
        oldDelegate.tipTarget.dy != tipTarget.dy;
  }

  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxWidth = this.maxWidth ?? constraints.maxWidth;
    double maxHeight = this.maxHeight ?? constraints.maxHeight;
    double minWidth = this.minWidth ?? constraints.minWidth;
    double minHeight = this.minHeight ?? constraints.minHeight;

    if (tooltipDirection == TooltipDirection.up ||
        tooltipDirection == TooltipDirection.down) {
      maxWidth = max(
        min(
          (constraints.maxWidth - tipTarget.dx).abs() * 2 - outsidePadding,
          (tipTarget.dx).abs() * 2 - outsidePadding,
        ),
        0,
      );
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    } else if (tooltipDirection == TooltipDirection.right) {
      maxWidth = max(
        (constraints.maxWidth - tipTarget.dx).abs() -
            outsidePadding -
            arrowLength -
            arrowTipDistance,
        0,
      );
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    } else if (tooltipDirection == TooltipDirection.left) {
      maxWidth = max(
          min(
            tipTarget.dx >= constraints.maxWidth
                ? (constraints.maxWidth - tipTarget.dx).abs() -
                    outsidePadding -
                    arrowLength -
                    arrowTipDistance
                : maxWidth,
            tipTarget.dx - (outsidePadding * 2) - arrowTipDistance,
          ),
          0);
      maxHeight = max(
        constraints.maxHeight - outsidePadding,
        0,
      );
    }

    return BoxConstraints(
      maxHeight: this.maxHeight ?? max(maxHeight, minHeight),
      maxWidth: this.maxWidth ?? max(maxWidth, minWidth),
      minHeight: this.minHeight ?? minHeight,
      minWidth: this.minWidth ?? minWidth,
    );
  }
}
