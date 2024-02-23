import 'package:flutter/material.dart';
import '/utils/color.dart';

class ScrollToTop extends StatefulWidget {
  const ScrollToTop(
      {Key? key,
      required this.child,
      required this.scrollController,
      this.scrollOffset = 500,
      this.btnColor = Colors.blue,
      this.txtColor = Colors.white})
      : super(key: key);

  final Widget child;
  final ScrollController scrollController;
  final int scrollOffset;
  final Color? btnColor;
  final Color? txtColor;

  @override
  State<ScrollToTop> createState() => _ScrollToTopState();
}

class _ScrollToTopState extends State<ScrollToTop>
    with SingleTickerProviderStateMixin {
  bool backToTop = true;
  int offset = 500;
  late AnimationController animationController;
  late Animation<double> animation;
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    animation = Tween<double>(begin: 10, end: 50).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        if (animationController.isCompleted) {
          animationController.reverse();
        } else if (animationController.isDismissed) {
          animationController.forward();
        }
      });
    });
    widget.scrollController.addListener(() {
      offset = (widget.scrollController.position.extentAfter +
              widget.scrollController.position.extentBefore)
          .toInt();
      setState(() {
        // print(widget.scrollController.offset.toInt());
        // print((widget.scrollController.position.extentAfter +
        //         widget.scrollController.position.extentBefore)
        //     .toInt());
        backToTop =
            (widget.scrollController.offset.toInt() < widget.scrollOffset) &&
                    widget.scrollController.offset.toInt() <
                        (widget.scrollController.position.extentAfter +
                                widget.scrollController.position.extentBefore)
                            .toInt()
                ? true
                : false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    widget.scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        buildBTT(widget.scrollController, backToTop, widget.btnColor,
            widget.txtColor),
      ],
    );
  }

  Widget buildBTT(ScrollController scrollController, bool backtoTop,
          Color? btnColor, Color? txtColor) =>
      backtoTop
          ? AnimatedBuilder(
              animation: animation,
              builder: (context, value) {
                return Positioned(
                  bottom: animation.value,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      // backgroundColor: btnColor,
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: appLogoColor,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          )),
                      onTap: () {
                        scrollController.animateTo(offset.toDouble(),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear);
                      },
                    ),
                  ),
                );
              })
          : const SizedBox();
}
