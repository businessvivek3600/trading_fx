import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';

class MyLoadMoreDelegate extends LoadMoreDelegate {
  MyLoadMoreDelegate({this.tColor = Colors.white});
  final Color tColor;
  @override
  double widgetHeight(LoadMoreStatus status) {
    return 30;
  }

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english}) {
    String text = builder(status);
    if (status == LoadMoreStatus.fail) {
      return Text(text.capitalize!, style: TextStyle(color: tColor));
    } else if (status == LoadMoreStatus.idle) {
      return Text('', style: TextStyle(color: tColor));
    } else if (status == LoadMoreStatus.loading) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 20,
                width: 20,
                margin: EdgeInsets.only(right: 10),
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 1)),

            // BouncingRotatingWidget(
            //     height: 20,
            //     bounceSpeed: 700,
            //     rotationSpeed: 2000,
            //     child: assetImages(PNGAssets.appLogo, width: 30)),
            /* const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blue, strokeWidth: 1.5),
            ),*/
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text.capitalize!, style: TextStyle(color: tColor)),
            ),
          ],
        ),
      );
    } else if (status == LoadMoreStatus.nomore) {
      return Text(text.capitalize!, style: TextStyle(color: tColor));
    } else {
      return Text(text.capitalize!, style: TextStyle(color: tColor));
    }
  }
}
