import 'package:flutter/material.dart';

enum SkeletonAnimation { none, pulse }

enum SkeletonStyle { box, circle, text }

class Skeleton extends StatefulWidget {
  final Color? textColor;
  final double width;
  final double height;
  final double padding;
  final SkeletonAnimation animation;
  final Duration? animationDuration;
  final SkeletonStyle style;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  Skeleton({
    this.textColor,
    this.width = 200.0,
    this.height = 60.0,
    this.padding = 0,
    this.animation = SkeletonAnimation.pulse,
    this.animationDuration,
    this.style = SkeletonStyle.box,
    this.border,
    this.borderRadius,
  });

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animation == SkeletonAnimation.pulse) {
      _controller = AnimationController(
        duration: widget.animationDuration ?? Duration(milliseconds: 1000),
        reverseDuration:
            widget.animationDuration ?? Duration(milliseconds: 1000),
        vsync: this,
        lowerBound: .6,
        upperBound: 1,
      )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        });
      _controller.forward();
    } else {
      _controller = AnimationController(
        vsync: this,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _themeTextColor = Theme.of(context).textTheme.bodyLarge!.color!;
    double _themeOpacity =
        Theme.of(context).brightness == Brightness.light ? 0.11 : 0.13;
    BorderRadiusGeometry _borderRadius = widget.borderRadius ??
        () {
          switch (widget.style) {
            case SkeletonStyle.circle:
              return BorderRadius.all(Radius.circular(widget.width / 2));
            case SkeletonStyle.text:
              return BorderRadius.all(Radius.circular(4));
            default:
              return BorderRadius.zero;
          }
        }();

    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: (widget.animation == SkeletonAnimation.pulse)
              ? _controller.value
              : 1,
          child: Container(
            width: widget.width,
            height: (widget.style == SkeletonStyle.circle)
                ? widget.width
                : widget.height,
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              border: widget.border,
              color: widget.textColor ??
                  _themeTextColor.withOpacity(_themeOpacity),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SkeletonText extends StatelessWidget {
  final double height;
  final double padding;

  const SkeletonText({
    required this.height,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      style: SkeletonStyle.text,
      height: this.height,
      padding: this.padding,
    );
  }
}
