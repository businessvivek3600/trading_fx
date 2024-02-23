import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/event_tickets_request_model.dart';
import '/providers/auth_provider.dart';
import '/providers/event_tickets_provider.dart';
import '/screens/drawerPages/event_tickets/buy_ticket_Page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventTicketsPage extends StatefulWidget {
  const EventTicketsPage({Key? key}) : super(key: key);
  static const String routeName = '/eventTicketsPage';

  @override
  State<EventTicketsPage> createState() => _EventTicketsPageState();
}

class _EventTicketsPageState extends State<EventTicketsPage> {
  var provider = sl.get<EventTicketsProvider>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.getEventTickets(true);
    });
  }

  Future<void> _onRefresh() async {
    provider.eventTicketsPage = 0;
    await provider.getEventTickets(false);
  }

  Future<void> _loadMore() async {
    await provider.getEventTickets(false);
  }

  @override
  void dispose() {
    provider.eventTicketsPage = 0;
    provider.loadingMyTickets = false;
    provider.totalRequests = 0;
    provider.ticketRequests.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color tColor = Colors.white;
    return Consumer<EventTicketsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: titleLargeText('My Events', context, useGradient: true)),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: LoadMoreContainer(
                finishWhen:
                    provider.ticketRequests.length >= provider.totalRequests,
                onLoadMore: _loadMore,
                onRefresh: _onRefresh,
                builder: (scrollController, status) {
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // SliverAppBar(
                      //   expandedHeight: Get.height * 0.3,
                      //   collapsedHeight: kToolbarHeight,
                      //   backgroundColor: Colors.transparent,
                      //   iconTheme: IconThemeData(color: Colors.white),
                      //   floating: true,
                      //   pinned: true,
                      //   leading: SizedBox(),
                      //   flexibleSpace: FlexibleSpaceBar(
                      //     collapseMode: CollapseMode.parallax,
                      //     centerTitle: true,
                      //     background: (provider.loadingMyTickets ||
                      //             provider.myEvents.isNotEmpty)
                      //         ? buildEventsList(provider)
                      //         : buildNoEvents(context),
                      //   ),
                      // ),
                      // SliverToBoxAdapter(child: Divider(color: Colors.white)),
                      SliverToBoxAdapter(
                          child: Container(
                        height: Get.height * 0.3,
                        child: (provider.loadingMyTickets ||
                                provider.eventsList.isNotEmpty)
                            // ? buildEventsList(provider)
                            ? const EventCards()
                            : buildNoEvents(context),
                      )),
                      if (!provider.loadingMyTickets &&
                          provider.ticketRequests.isEmpty)
                        const SliverToBoxAdapter(
                            child: Divider(color: Colors.white54)),
                      (provider.loadingMyTickets ||
                              provider.ticketRequests.isNotEmpty)
                          ? buildTicketList(provider, tColor)
                          : buildEmptyTickets(context),
                    ],
                  );
                }),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter buildEmptyTickets(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      height: Get.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.history, color: Colors.white, size: Get.height * 0.1),
          assetSvg(Assets.eventTicket,
              height: Get.height * 0.1, color: Colors.white),
          height20(),
          Center(
            child: bodyLargeText('Event history not found.', context,
                color: Colors.white),
          ),
        ],
      ),
    ));
  }

  SliverList buildTicketList(EventTicketsProvider provider, Color tColor) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            childCount: provider.loadingMyTickets
                ? 10
                : provider.ticketRequests.length, (context, i) {
      var request = EventTicketsRequests();
      if (!provider.loadingMyTickets) {
        request = provider.ticketRequests[i];
      }
      return
          // !provider.loadingMyTickets
          //   ?
          GestureDetector(
        onTap: () {
          // Get.to(Scaffold(
          //   appBar: AppBar(
          //     title: bodyLargeText(request.name ?? '', context),
          //   ),
          //   body: SfPdfViewer.network(
          //       'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'),
          // ));
          // launchTheLink(
          //     'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          padding: const EdgeInsets.all(8),
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black54,
              boxShadow: [
                const BoxShadow(
                    color: Colors.white12,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(2, 2))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleLargeText('Ticket No.', context, color: tColor),
                  provider.loadingMyTickets
                      ? Skeleton(
                          width: 150,
                          height: 15,
                          textColor: Colors.white30,
                          borderRadius: BorderRadius.circular(10))
                      : capText(
                          DateFormat().add_yMMMMd().add_jm().format(
                                DateTime.parse(request.createdAt ?? ""),
                              ),
                          context,
                          color: tColor,
                          fontWeight: FontWeight.w500)
                ],
              ),
              height5(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      provider.loadingMyTickets
                          ? Skeleton(
                              width: 70,
                              height: 15,
                              textColor: Colors.white30,
                              borderRadius: BorderRadius.circular(5))
                          : bodyMedText(request.orderId ?? '', context,
                              color: tColor),
                      width5(),
                      if (!provider.loadingMyTickets)
                        GestureDetector(
                          onTap: () async => await Clipboard.setData(
                                  ClipboardData(text: request.orderId ?? ''))
                              .then((value) => Fluttertoast.showToast(
                                  msg: 'Ticket code copied!',
                                  backgroundColor: mainColor)),
                          child: const Icon(Icons.content_copy_rounded,
                              size: 13, color: Colors.amber),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!provider.loadingMyTickets)
                        GestureDetector(
                            onTap: () async =>
                                Get.to(EventDetailsPage(request: request)),
                            child: bodyLargeText('View', context,
                                color: CupertinoColors.link)),
                      width10(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: provider.loadingMyTickets
                              ? Colors.grey
                              : ((request.paymentStatus == '2'
                                      ? Colors.red
                                      : request.paymentStatus == '1'
                                          ? Colors.green
                                          : Colors.amber))
                                  .withOpacity(1),
                        ),
                        child: Center(
                          child: provider.loadingMyTickets
                              ? Skeleton(
                                  width: 70,
                                  height: 15,
                                  textColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5))
                              : capText(
                                  request.paymentStatus == '2'
                                      ? 'Failed'
                                      : request.paymentStatus == '1'
                                          ? 'Paid'
                                          : 'Pending',
                                  context,
                                  fontWeight: FontWeight.bold,

                                  // color: (request.paymentStatus == '2'
                                  //     ? Colors.red
                                  //     : request.paymentStatus == '1'
                                  //         ? Colors.green
                                  //         : Colors.amber),
                                ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      )
          // : Container(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Skeleton(
          //         width: 150,
          //         height: 70,
          //         textColor: Colors.white30,
          //         borderRadius: BorderRadius.circular(10)),
          //   )
          ;
    }));
  }

  ListView buildEventsList(EventTicketsProvider provider) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        if (!provider.loadingMyTickets)
          ...provider.eventsList.map((e) => GestureDetector(
                onTap: () {
                  provider.buyEventTicketsRequest(e.id ?? '');
                  Get.to(BuyEventTicket(event: e));
                },
                // child: Hero(
                //   tag: '${e.eventName}+${e.eventBanner}',
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                            imageUrl: e.eventBanner ?? '',
                            placeholder: (context, url) => SizedBox(
                                height: 50,
                                width: 100,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: appLogoColor.withOpacity(0.5)))),
                            errorWidget: (context, url, error) =>
                                assetImages(Assets.noImage),
                            cacheManager: CacheManager(Config(
                                "${AppConstants.packageID}_${e.eventName}",
                                stalePeriod: const Duration(days: 7)))),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              // color: appLogoColor,
                              gradient: const LinearGradient(
                                  colors: [Colors.black, Colors.black38]),
                              // backgroundBlendMode: BlendMode.srcOver,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                capText('Book Now', context,
                                    color: appLogoColor,
                                    fontWeight: FontWeight.bold),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: appLogoColor,
                                  size: 13,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // ),
              )),
        if (provider.loadingMyTickets)
          ...[1, 2, 3, 4, 5, 6].map(
            (e) => Container(
              padding: const EdgeInsets.all(8.0),
              child: Skeleton(
                  width: 150,
                  textColor: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  Column buildNoEvents(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: Colors.white, size: Get.height * 0.1),
              height20(),
              bodyLargeText('No Active Event', context, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class EventCards extends StatelessWidget {
  const EventCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventTicketsProvider>(
      builder: (context, provider, child) {
        return CarouselSlider(
            items: <Widget>[
              if (!provider.loadingMyTickets)
                ...provider.eventsList.map((e) => GestureDetector(
                    onTap: () =>
                        checkServiceEnableORDisable('mobile_is_event', () {
                          provider.buyEventTicketsRequest(e.id ?? '');
                          Get.to(BuyEventTicket(event: e));
                        }),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(children: [
                          CachedNetworkImage(
                            imageUrl: e.eventBanner ?? '',
                            placeholder: (context, url) => SizedBox(
                                height: 50,
                                width: 100,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: appLogoColor.withOpacity(0.5)))),
                            errorWidget: (context, url, error) =>
                                assetImages(Assets.noImage),
                            cacheManager: CacheManager(Config(
                              "${AppConstants.packageID}_${e.eventName}",
                              stalePeriod: const Duration(days: 7),
                              //one week cache period
                            )),
                          ),
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0),
                                      gradient: const LinearGradient(colors: [
                                        Colors.black,
                                        Colors.black38
                                      ])),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        capText('Book Now', context,
                                            color: appLogoColor,
                                            fontWeight: FontWeight.bold),
                                        const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: appLogoColor,
                                            size: 13)
                                      ])))
                        ])))),
              if (provider.loadingMyTickets)
                ...[1, 2, 3, 4, 5, 6].map((e) => Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Skeleton(
                        width: 150,
                        textColor: Colors.white30,
                        borderRadius: BorderRadius.circular(10))))
            ],
            options: CarouselOptions(
              // height: 400,
              // aspectRatio: 16 / 9,
              viewportFraction: 0.5,
              initialPage: 0,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: false,
              // disableCenter: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              // onPageChanged: callbackFunction,
              scrollDirection: Axis.horizontal,
            ));
      },
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.request});
  final EventTicketsRequests request;

  @override
  Widget build(BuildContext context) {
    print(request.toJson());
    return Scaffold(
      appBar: AppBar(
        title: bodyLargeText(request.name ?? '', context),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CachedNetworkImage(
            imageUrl: request.image ?? '',
            placeholder: (context, url) => SizedBox(
                height: 50,
                width: 100,
                child: Center(
                    child: CircularProgressIndicator(
                        color: appLogoColor.withOpacity(0.5)))),
            errorWidget: (context, url, error) => assetImages(Assets.noImage),
            cacheManager: CacheManager(Config(
              "${AppConstants.packageID}_event_tickets_${request.image ?? ''}",
              stalePeriod: const Duration(days: 7),
              //one week cache period
            )),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF271228),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleLargeText(
                    'Dear ${(request.customerName ?? '').capitalize!}', context,
                    fontSize: 22)
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xF0E7BF51),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: titleLargeText(
                      'Your ticket has been confirmed.', context,
                      fontSize: 22, textAlign: TextAlign.center),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF292645),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    titleLargeText('Ticket No. ', context, fontSize: 22),
                    titleLargeText('${request.orderId ?? ''}', context),
                  ],
                ),
                Column(
                  children: [
                    titleLargeText('Price: ', context, fontSize: 22),
                    bodyLargeText(
                        '${sl.get<AuthProvider>().userData.currency_icon ?? ''}${request.amount ?? ''}',
                        context),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1F1A40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                titleLargeText('No. of Members', context, fontSize: 22),
                height5(),
                titleLargeText('${request.member ?? 0}', context, fontSize: 25),
                height5(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(50),
            color: const Color(0xFF1F1A40),
            child: Center(
              child: QrImageView(
                backgroundColor: Colors.white,
                data: request.orderId ?? '',
                version: QrVersions.auto,
                gapless: false,
                foregroundColor: Colors.black,
                embeddedImage:
                    assetImageProvider(Assets.appLogo_S, fit: BoxFit.contain),
                embeddedImageStyle:
                    const QrEmbeddedImageStyle(size: Size(50, 40)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
