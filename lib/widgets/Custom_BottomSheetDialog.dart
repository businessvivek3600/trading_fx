import 'package:flutter/material.dart';

class AnimatedBottomSheetDialogWidget extends StatefulWidget {
  const AnimatedBottomSheetDialogWidget(
      {super.key, required this.child, this.bgColor});
  final Widget child;
  final Color? bgColor;

  @override
  State<AnimatedBottomSheetDialogWidget> createState() =>
      _AnimatedBottomSheetDialogWidgetState();
}

class _AnimatedBottomSheetDialogWidgetState
    extends State<AnimatedBottomSheetDialogWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation =
        CurveTween(curve: Curves.bounceInOut).animate(animationController);
    animationController.addListener(() => setState(() {}));
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => Navigator.pop(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, animation.value),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: widget.bgColor ?? Colors.white),
                    child: widget.child,
                  ),
                );
              }),
        ],
      ),
    );
  }
}
