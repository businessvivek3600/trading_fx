import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

import '../database/functions.dart';

class RatingDialog extends StatefulWidget {
  RatingDialog();

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0.0;
  @override
  Widget build(BuildContext context) {
    Widget androidDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Rate Our App', textAlign: TextAlign.center),
      content: buildContent(),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              launchPlayStore();
            } else if (Platform.isIOS) {
              launchAppStore();
            }
          },
          child: const Text('Rate Now'),
        ),
      ],
    );
    Widget cupertinoDialog = CupertinoAlertDialog(
      title: const Text('Rate Our App'),
      content: buildContent(),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            // Perform action when user submits rating
            Navigator.of(context).pop();
            if (Platform.isAndroid) {
              launchPlayStore();
            } else if (Platform.isIOS) {
              launchAppStore();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
    return (Platform.isIOS ? cupertinoDialog : androidDialog);
  }

  buildContent() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('We would love to hear your feedback!',
              style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 25,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(CupertinoIcons.star_fill,
                color: CupertinoColors.systemYellow),
            onRatingUpdate: (rating) {
              setState(() => _rating = rating);
            },
          ),
        ],
      );
}

rateApp() async {
  final InAppReview inAppReview = InAppReview.instance;
  // if ((await inAppReview.isAvailable())) {
  //   inAppReview.requestReview();
  // } else {
  showCupertinoDialog(
      context: Get.context!, builder: (context) => RatingDialog());
  // }
}
