import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/utils/default_logger.dart';

import '../constants/assets_constants.dart';
import '../utils/picture_utils.dart';

class GalleryDetailsImagePopup extends StatefulWidget {
  const GalleryDetailsImagePopup(
      {Key? key,
      required this.currentIndex,
      required this.images,
      this.showCancel = false})
      : super(key: key);
  final int currentIndex;
  final bool showCancel;
  final List<String> images;

  @override
  State<GalleryDetailsImagePopup> createState() =>
      _GalleryDetailsImagePopupState();
}

class _GalleryDetailsImagePopupState extends State<GalleryDetailsImagePopup> {
  late int currentIndex;
  bool hasPrevious = true;
  bool hasNext = true;
  @override
  void initState() {
    currentIndex = widget.currentIndex;
    super.initState();
    print(
        'current index is: ${widget.currentIndex}  and images list : ${widget.images}');
  }

  previous() async =>
      currentIndex != 0 ? setState(() => currentIndex--) : showAlert(false);
  next() async => currentIndex != widget.images.length - 1
      ? setState(() => currentIndex++)
      : showAlert(true);
  showAlert(bool end) => widget.showCancel
      ? null
      : Fluttertoast.showToast(
          msg: end ? 'No more images' : 'This is first image',
          backgroundColor: Colors.white24);
  @override
  Widget build(BuildContext context) {
    infoLog(
        'popup img --> current index image is: ${widget.images[currentIndex]}');
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        print(details);
        if (details.velocity.pixelsPerSecond.dx > 0) {
          previous();
        }
        if (details.velocity.pixelsPerSecond.dx < 0) {
          next();
        }
      },
      onVerticalDragEnd: (details) {
        print('vertical drag details---> ${details}');
        if (details.velocity.pixelsPerSecond.dx < -100 ||
            details.velocity.pixelsPerSecond.dx > 100) {
          Get.back();
        }
      },
      child: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                child: buildCachedNetworkImage(widget.images[currentIndex],
                    fit: BoxFit.fill, pw: Get.width / 2, ph: Get.width / 2),
              ),
            ),
          ),
          // Center(child: titleLargeText(currentIndex.toString(), context)),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Visibility(
                  visible: currentIndex != 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      print(details);
                    },
                    onTap: previous,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: currentIndex != widget.images.length - 1,
                  child: GestureDetector(
                    onTap: next,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showCancel)
            Positioned(
              right: 10,
              top: kToolbarHeight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
