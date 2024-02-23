
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/CardDetailsPurchasedHistoryModel.dart';
import '/screens/dashboard/CardFeature/main_page_card_details.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class MainPageCardHistory extends StatefulWidget {
  const MainPageCardHistory({Key? key, required this.cards}) : super(key: key);

  final List<CardDetailsPurchasedHistoryModel> cards;
  @override
  State<MainPageCardHistory> createState() => _MainPageCardHistoryState();
}

class _MainPageCardHistoryState extends State<MainPageCardHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
          title: titleLargeText('Cards History',context,useGradient: true),
          elevation: 1,
          shadowColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 1),
        ),
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            if (widget.cards.isNotEmpty)
              ...widget.cards.map((card) {
                int index = widget.cards.indexOf(card);
                return _BuyCreditCardHistoryWidget(card: card, index: index);
              })
          ],
        ),
      ),
    );
  }
}

class _BuyCreditCardHistoryWidget extends StatefulWidget {
  const _BuyCreditCardHistoryWidget({
    required this.card,
    required this.index,
  });
  final CardDetailsPurchasedHistoryModel card;
  final int index;

  @override
  State<_BuyCreditCardHistoryWidget> createState() =>
      _BuyCreditCardHistoryWidgetState();
}

class _BuyCreditCardHistoryWidgetState
    extends State<_BuyCreditCardHistoryWidget>
    with SingleTickerProviderStateMixin {
  var _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _tileAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _tileAnimation =
        Tween<double>(begin: (-(100 * widget.index)).toDouble(), end: 0)
            .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String paymentStatus = widget.card.paymentStatus ?? '0';
    String deliveryStatus = widget.card.deliveryStatus ?? '0';

    return AnimatedBuilder(
        animation: _tileAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(_tileAnimation.value, 0),
            child: GestureDetector(
              onTap: () {
                Get.to(CardDetailsPage(card: widget.card));
              },
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: assetImages(paymentStatus == '2'
                          ? Assets.failedImg
                          : paymentStatus == '0'
                              ? Assets.pendingImg
                              : Assets.doneImg),
                    ),
                    SizedBox(
                        height: 40,
                        child: VerticalDivider(color: Colors.white54)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              titleLargeText(widget.card.type ?? '', context,
                                  color: Colors.white),
                            ],
                          ),
                          height5(),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color: Colors.white54),
                                      width: 25,
                                      height: 5),
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color: deliveryStatus == '2'
                                              ? Colors.red
                                              : deliveryStatus == '1'
                                                  ? Colors.green
                                                  : Colors.amber),
                                      width: deliveryStatus == '2' ||
                                              deliveryStatus == '1'
                                          ? 25
                                          : 5,
                                      height: 5),
                                ],
                              ),
                              width5(),
                              capText(
                                  deliveryStatus == '2'
                                      ? 'Delivery Failed'
                                      : deliveryStatus == '1'
                                          ? 'Delivered'
                                          : 'Delivery Pending',
                                  context,
                                  fontWeight: FontWeight.bold,
                                  color: deliveryStatus == '2'
                                      ? Colors.red
                                      : deliveryStatus == '1'
                                          ? Colors.green
                                          : Colors.amber)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.card.createdAt != null)
                                capText(
                                    formatDateTime(
                                        DateTime.parse(widget.card.createdAt!)),
                                    context,
                                    color: Colors.white)
                            ],
                          )
                        ],
                      ),
                    ),
                    width5(),
                    assetSvg(Assets.arrowForwardIos,
                        color: Colors.white70, width: 20),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
