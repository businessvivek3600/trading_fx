import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/event_tickets_model.dart';
import '/providers/event_tickets_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class BuyEventTicket extends StatefulWidget {
  const BuyEventTicket({required this.event, Key? key}) : super(key: key);
  final EventTickets event;
  @override
  State<BuyEventTicket> createState() => _BuyEventTicketState();
}

class _BuyEventTicketState extends State<BuyEventTicket>
    with SingleTickerProviderStateMixin {
  String selectedPayment = '';
  String selectedType = '';
  int members = 0;
  double scale = 1;
  double minScale = 1;
  double maxScale = 4;
  late AnimationController animationController;
  late Animation<double> animation;
  late Animation<Matrix4> zoomAnimation;
  late TransformationController controller;
  late TransformationController sliverController;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    controller = TransformationController();
    sliverController = TransformationController();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animationController.addListener(() {
      controller.value = zoomAnimation.value;
      sliverController.value = zoomAnimation.value;
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // removeOverlay();
      }
    });
    animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(animationController);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    sliverController.dispose();
    animationController.dispose();
    sl.get<EventTicketsProvider>().selectedTicket = null;
    sl.get<EventTicketsProvider>().paymentTypes.clear();
    super.dispose();
  }

  resetAnimation() {
    zoomAnimation =
        Matrix4Tween(begin: controller.value, end: Matrix4.identity()).animate(
            CurvedAnimation(
                parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (overlayEntry == null) {
          return true;
        } else {
          overlayEntry?.remove();
          overlayEntry = null;
          return false;
        }
      },
      child: Consumer<EventTicketsProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            extendBody: true,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  [buildSliverAppBar()],
              body: buildForm(provider, context),
            ),
          );
        },
      ),
    );
  }

  void _showOverlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    overlayEntry = OverlayEntry(builder: (context) {
      final opacity = ((scale - 1) / (maxScale - 1)).clamp(0, 1);
      return Stack(
        children: [
          Positioned.fill(
              child:
                  Opacity(opacity: 1, child: Container(color: Colors.black))),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: Get.width,
            height: Get.height,
            child: InteractiveViewer(
              transformationController: controller,
              maxScale: maxScale,
              minScale: minScale,
              panEnabled: true,
              onInteractionStart: (details) {
                print('start ${details}');
                if (details.pointerCount < 2) return;
                // if (overlayEntry == null) {
                //   _showOverlay(context);
                // }
                // ;
              },
              onInteractionUpdate: (details) {
                if (overlayEntry == null) return;
                this.scale = details.scale;
                overlayEntry!.markNeedsBuild();
              },
              onInteractionEnd: (details) {
                if (details.pointerCount != 1) return;
                resetAnimation();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildImage(),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: appLogoColor),
              child: GestureDetector(
                onTap: () => removeOverlay(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.zoom_in_map_rounded, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      );
    });
    overlayState.insert(overlayEntry!);
    setState(() {});
  }

  removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Widget buildForm(EventTicketsProvider provider, BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white30,
          // padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: !provider.loadingBuyEventTickets &&
                  provider.selectedTicket != null
              ? Column(
                  children: [
                    height10(),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20)),
                            color: appLogoColor),
                        child: bodyMedText(
                            'Wallet Balance ${sl.get<AuthProvider>().userData.currency_icon ?? ''}${provider.walletBalance.toStringAsFixed(1)}',
                            context,
                            color: Colors.white),
                      )
                    ]),
                    height10(),
                    titleLargeText('Ticket Type', context, color: Colors.black),
                    height10(),
                    ...provider.selectedTicket!.ticketType!
                        .map((e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedType = e.amount ?? '0';
                                  members = e.member ?? 0;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: 55,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: RadioListTile(
                                  activeColor: appLogoColor,
                                  tileColor: selectedType == e.amount
                                      ? appLogoColor.withOpacity(0.3)
                                      : Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                  title: bodyMedText(e.text ?? "", context,
                                      color: Colors.black),
                                  value: e.amount!,
                                  groupValue: selectedType,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedType = e.amount ?? '0';
                                      members = e.member ?? 0;
                                    });
                                  },
                                ),
                              ),
                            )),
                    height30(),
                    titleLargeText('Payment Type', context,
                        color: Colors.black),
                    height20(),
                    ...provider.paymentTypes.entries.map((e) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPayment = e.key;
                          });
                        },
                        child: Container(
                            color: Colors.transparent,
                            height: 55,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: RadioListTile(
                                activeColor: appLogoColor,
                                tileColor: selectedPayment == e.key
                                    ? appLogoColor.withOpacity(0.3)
                                    : Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                title: bodyMedText(e.value ?? "", context,
                                    color: Colors.black),
                                value: e.key,
                                groupValue: selectedPayment,
                                onChanged: (val) {
                                  setState(() {
                                    selectedPayment = e.key;
                                  });
                                })))),
                    height50(),
                    OutlinedButton(
                        onPressed: selectedPayment != '' && selectedType != ''
                            ? () => provider.buyTicketSubmit(
                                payment_type: selectedPayment,
                                amount: selectedType,
                                member: members,
                                event_id: widget.event.id ?? '')
                            : null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: appLogoColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            disabledBackgroundColor: Colors.grey),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: bodyLargeText('Buy Now', context,
                              useGradient: false),
                        )),
                  ],
                )
              : SizedBox(
                  height: Get.height * 0.4,
                  child: Center(child: appLoadingDots())),
        ),
      ],
    );
  }

  Widget buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: Get.height * 0.5,
      iconTheme: const IconThemeData(color: Colors.white),
      floating: true,
      pinned: true,
      leadingWidth: 40,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20))),
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
        child: FlexibleSpaceBar(
          expandedTitleScale: 1.3,
          titlePadding: EdgeInsets.zero,
          title: Container(
              padding: const EdgeInsets.only(left: 40, bottom: 15, right: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Text(widget.event.eventName ?? "",
                  textAlign: TextAlign.center)),
          background: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(width: Get.width, child: buildImage()),
              Positioned(
                  top: 50,
                  right: 10,
                  child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: appLogoColor),
                      child: GestureDetector(
                          onTap: () => _showOverlay(context),
                          child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(Icons.zoom_out_map_rounded,
                                  color: Colors.white, size: 18)))))
            ],
          ),
        ),
      ),
    );
  }

  CachedNetworkImage buildImage() {
    return CachedNetworkImage(
        imageUrl: widget.event.eventBanner ?? '',
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => SizedBox(
            height: 50,
            width: 100,
            child: Center(
                child: CircularProgressIndicator(
                    color: appLogoColor.withOpacity(0.5)))),
        errorWidget: (context, url, error) => assetImages(Assets.noImage),
        cacheManager: CacheManager(Config(
            "${AppConstants.packageID}_${widget.event.eventName}",
            stalePeriod: const Duration(days: 7))));
  }
}
