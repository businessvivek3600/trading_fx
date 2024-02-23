import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/CardDetailsPurchasedHistoryModel.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class CardDetailsPage extends StatefulWidget {
  const   CardDetailsPage({Key? key, required this.card}) : super(key: key);
  final CardDetailsPurchasedHistoryModel card;

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _headerAnimation;
  late Animation<double> _toolsAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationController.forward();
    _headerAnimation = Tween<double>(begin: -100, end: 0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _animationController..duration = Duration(milliseconds: 2000);
    _cardAnimation = Tween<double>(begin: -300, end: 0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    _animationController..duration = Duration(milliseconds: 3000);
    _toolsAnimation = Tween<double>(begin: Get.width, end: 0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  var dashProvider = sl.get<DashBoardProvider>();
  String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double offset = 2;
    return Scaffold(
      backgroundColor: Colors.grey[900]?.withOpacity(0.6),
      body: Stack(
        children: [
          Container(height: double.maxFinite, width: double.maxFinite),
          buildStackHeader(context),
          SingleChildScrollView(
            child: Column(
              children: [
                buildHeaderDetails(context, widget.card),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  // height: 400,
                  width: double.maxFinite,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleLargeText('Card Details', context),
                      height10(),
                      buildImageWidget(size, offset, dashProvider, widget.card),
                      height10(),
                    ],
                  ),
                ),
                height20(),
                buildPurchaseDetails(widget.card),
                height20(),
                if (widget.card.createdAt != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      capText(
                          'Card applied on ${DateFormat().add_yMMMMd().format(DateTime.parse(widget.card.createdAt!))}',
                          context)
                    ],
                  ),
                height10()
                // height50(500),
              ],
            ),
          ),
          buildBackButton(),
        ],
      ),
    );
  }

  AnimatedBuilder buildPurchaseDetails(CardDetailsPurchasedHistoryModel card) {
    String payMethod = '';
    var provider = sl.get<DashBoardProvider>();
    if (provider.cardDetail != null &&
        (provider.cardDetail!.paymentType != null ||
            provider.cardDetail!.paymentType!.isNotEmpty)) {
      payMethod = provider.cardDetail!.paymentType!.entries
          .firstWhere((element) => element.key == card.paymentType)
          .value;
    }
    return AnimatedBuilder(
        animation: _toolsAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(_toolsAnimation.value, 0),
            child: Container(
              width: double.maxFinite,
              // height: 120,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Order ID	: ', context,
                          color: Colors.white70),
                      bodyLargeText(card.orderId ?? '', context,
                          color: Colors.white70),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Quantity	: ', context,
                          color: Colors.white70),
                      bodyLargeText(card.quantity ?? '', context,
                          color: Colors.white70),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Fees on purchase: ', context,
                          color: Colors.white70),
                      bodyLargeText(
                          '${currency_icon}${card.amount ?? '0'}', context,
                          color: Colors.white70),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Payment method: ', context,
                          color: Colors.white70),
                      bodyLargeText(payMethod, context,
                          color: Color(0xFF36F3ED), fontSize: 15),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Payment Status	: ', context, fontSize: 15),
                      capText(
                          (card.paymentStatus == '2'
                                  ? 'Payment Failed'
                                  : card.paymentStatus == '1'
                                      ? 'Paid'
                                      : 'Payment Pending')
                              .toUpperCase(),
                          context,
                          fontWeight: FontWeight.bold,
                          color: card.paymentStatus == '2'
                              ? Colors.red
                              : card.paymentStatus == '1'
                                  ? Colors.green
                                  : Colors.amber),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      capText('Delivery Status : ', context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            card.deliveryStatus == '0'
                                ? Icons.delivery_dining
                                : card.deliveryStatus == '1'
                                    ? Icons.delivery_dining
                                    : Icons.delivery_dining_outlined,
                            color: card.deliveryStatus == '0'
                                ? Colors.amber
                                : card.deliveryStatus == '1'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          width5(),
                          capText(
                            (card.deliveryStatus == '2'
                                    ? 'Delivery Rejected'
                                    : card.deliveryStatus == '1'
                                        ? 'Delivered'
                                        : 'Pending')
                                .toUpperCase(),
                            context,
                            color: card.deliveryStatus == '0'
                                ? Colors.amber
                                : card.deliveryStatus == '1'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  height10(),
                  bodyLargeText(
                      'You can receive your card from ${card.deliveryType == 'office' || card.deliveryType == 'office' ? card.deliveryType : 'your shipping address'}.',
                      context,
                      color: Colors.white70,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        });
  }

  Stack buildStackHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: assetImageProvider(Assets.appWebLogoWhite),
                fit: BoxFit.contain,
              ),
              gradient: LinearGradient(colors: [
                Colors.white30,
                Colors.black87,
              ])),
          height: 300,
          width: double.maxFinite,
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black38,
            Colors.black54,
            Colors.black87,
            Colors.black,
          ])),
          height: 300,
          width: double.maxFinite,
        ),
      ],
    );
  }

  Widget buildHeaderDetails(
      BuildContext context, CardDetailsPurchasedHistoryModel card) {
    return AnimatedBuilder(
        animation: _headerAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, -_headerAnimation.value),
            child: Container(
              height: 260,
              width: double.maxFinite,
              padding: EdgeInsets.all(10),
              child: SafeArea(
                child: Row(
                  children: [
                    SizedBox(width: Get.width * 0.5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height5(),
                          capText('Welcome', context, color: Colors.white70),
                          height5(),
                          titleLargeText(
                              (card.firstName ?? '') +
                                  ' ' +
                                  (card.lastName ?? ''),
                              context),
                          height20(),
                          capText('Your Phone Number on Card', context,
                              color: Colors.white70),
                          height5(),
                          bodyLargeText(card.phoneNo ?? '', context)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  AnimatedBuilder buildImageWidget(Size size, double offset,
      DashBoardProvider dashProvider, CardDetailsPurchasedHistoryModel _card) {
    var card = dashProvider.cards
        .firstWhere((element) => element['name'] == _card.type);
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_cardAnimation.value, 0),
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: buildCachedNetworkImage(card['image'],
                      pw: size.width * 0.8,
                      ph: double.maxFinite,
                      errorBgColor: Colors.white70,
                      placeholderBgColor: Colors.white70,
                      errorStackChild: Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              bodyLargeText(
                                'Platinum Card',
                                context,
                                color: Colors.white,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(offset, offset),
                                      blurRadius: 8.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    Shadow(
                                        offset: Offset(offset, offset),
                                        blurRadius: 8.0,
                                        color: appLogoColor),
                                  ],
                                ),
                              )
                            ],
                          ))),
                ),
                Positioned(
                    right: widget.card.type == 'Visa Card' ? null : 20,
                    left: widget.card.type == 'Visa Card' ? 30 : null,
                    bottom: widget.card.type == 'Visa Card' ? 5 : null,
                    top: widget.card.type == 'Visa Card' ? null : 75,
                    child: titleLargeText(
                        calculateName(_card.firstName, _card.lastName), context,
                        textAlign: TextAlign.start)),
                if (card['qr_code'] != null)
                  Positioned(
                      left: 30,
                      bottom: 75,
                      child: SizedBox(
                          height: 60,
                          width: 60,
                          child: buildCachedNetworkImage(card['qr_code'])))
              ],
            ),
          ),
        );
      },
    );
  }

  String calculateName(String? fName, String? lName) {
    String nameOnCard = '';
    nameOnCard = '${fName ?? ""} ${lName ?? ''}';
    return nameOnCard;
  }

  Positioned buildBackButton() {
    return Positioned(
      top: kToolbarHeight,
      left: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              width: 40.0,
              height: 40.0,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white30),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
