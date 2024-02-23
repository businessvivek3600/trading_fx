import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/load_more_container.dart';
import '../../database/model/response/company_info_model.dart';
import '../../providers/dashboard_provider.dart';
import '/constants/assets_constants.dart';
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

class PinManagementPage extends StatefulWidget {
  const PinManagementPage({Key? key}) : super(key: key);
  static const String routeName = '/pinManagementPage';

  @override
  State<PinManagementPage> createState() => _PinManagementPageState();
}

class _PinManagementPageState extends State<PinManagementPage> {
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
        CompanyInfoModel? companyInfo = sl.get<DashBoardProvider>().companyInfo;
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
            title: titleLargeText('Pin Management', context, useGradient: true),
            actions: [
              IconButton(
                  onPressed: () => Get.to(BuyPinPage(
                        packages: provider.packages,
                        accountInfo: companyInfo?.accountInfo ?? '',
                        accountImage: companyInfo?.qrCode ?? '',
                        fileSize: provider.fileSize,
                      )),
                  icon: const Icon(Icons.add))
            ],
          ),
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
      child: SizedBox(
        height: Get.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.history, color: Colors.white, size: Get.height * 0.1),
            assetSvg(Assets.eventTicket,
                height: Get.height * 0.1, color: Colors.white),
            height20(),
            Center(
              child: bodyLargeText('Pins not found.', context,
                  color: Colors.white),
            ),
            height20(kToolbarHeight),
            // RetryButton(onRetry: () => provider.getEventTickets(true))
          ],
        ),
      ),
    );
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
      String currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
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
              boxShadow: const [
                BoxShadow(
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
                  provider.loadingMyTickets
                      ? Skeleton(
                          width: 150,
                          height: 15,
                          textColor: Colors.white30,
                          borderRadius: BorderRadius.circular(5))
                      : titleLargeText(
                          "${request.name ?? ""} (${request.bizz ?? ''})",
                          context,
                          color: tColor),
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
                          : bodyMedText(
                              currencyIcon + (request.amount ?? ''), context,
                              color: tColor),
                      // width5(),
                      // if (!provider.loadingMyTickets)
                      //   GestureDetector(
                      //     onTap: () async => await Clipboard.setData(
                      //             ClipboardData(text: request.orderId ?? ''))
                      //         .then((value) => Fluttertoast.showToast(
                      //             msg: 'Ticket code copied!',
                      //             backgroundColor: mainColor)),
                      //     child: const Icon(Icons.content_copy_rounded,
                      //         size: 13, color: Colors.amber),
                      //   ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!provider.loadingMyTickets &&
                          request.image != null &&
                          request.image!.isNotEmpty)
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
                              : ((request.status == '2'
                                      ? Colors.red
                                      : request.status == '1'
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
                                  request.status == '2'
                                      ? 'Disapproved'
                                      : request.status == '1'
                                          ? 'Approved'
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

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.request});
  final EventTicketsRequests request;

  @override
  Widget build(BuildContext context) {
    print(request.toJson());
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: bodyLargeText(request.name ?? '', context),
      ),
      body:
          // ListView(
          //   padding: EdgeInsets.zero,
          //   children: [
          CachedNetworkImage(
        imageUrl: AppConstants.imageUrl + (request.image ?? ''),
        imageBuilder: (context, imageProvider) => Container(
            decoration:
                BoxDecoration(image: DecorationImage(image: imageProvider))),
        placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
                color: appLogoColor.withOpacity(0.5))),
        errorWidget: (context, url, error) =>
            Center(child: assetImages(Assets.noImage)),
        cacheManager: CacheManager(Config(
          "${AppConstants.packageID}_event_tickets_${request.image ?? ''}",
          stalePeriod: const Duration(days: 7),
          //one week cache period
        )),
      ),
      /*
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
        
        */
      // ],
      // ),
    );
  }
}

class BuyPinPage extends StatefulWidget {
  const BuyPinPage({
    super.key,
    required this.packages,
    required this.accountInfo,
    required this.accountImage,
    required this.fileSize,
  });
  final List<Map<String, dynamic>> packages;
  final String accountInfo;
  final String accountImage;
  final double fileSize;

  @override
  State<BuyPinPage> createState() => _BuyPinPageState();
}

class _BuyPinPageState extends State<BuyPinPage> {
  final _formKey = GlobalKey<FormState>();
  double amount = 100;
  int noOfPin = 1;
  XFile? choosedImage;
  final pinCountController = TextEditingController();
  final transactionController = TextEditingController();
  final amountController = TextEditingController();
  final acName = TextEditingController();
  final acNumber = TextEditingController();
  final bcName = TextEditingController();
  final uploadSlip = TextEditingController();
  Map<String, dynamic>? selectedPackage;
  int max = 1;
  @override
  void initState() {
    super.initState();
    pinCountController.text = noOfPin.toString();
  }

  submit() async {
    if ((_formKey.currentState?.validate() ?? false) == false) return;
    _formKey.currentState?.save();
    if (selectedPackage == null) {
      Fluttertoast.showToast(msg: 'Please select a package');
      return;
    }
    if (choosedImage == null) {
      Fluttertoast.showToast(msg: 'Please upload the transfer slip');
      return;
    }
    var data = {
      'customer_name': sl.get<AuthProvider>().userData.customerName ?? '',
      'username': sl.get<AuthProvider>().userData.username ?? '',
      'package_id': selectedPackage?['id'].toString() ?? '',
      'package_amt': amount.toString(),
      'no_of_pin': noOfPin.toString(),
      'transaction_number': transactionController.text,
      'account_name': acName.text,
      'account_number': acNumber.text,
      'bank_name': bcName.text,
    };
    await sl
        .get<EventTicketsProvider>()
        .buyPinRequest(data, {'transfer_slip': choosedImage?.path ?? ''});
  }

  uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      /// file size check
      double sizeInKb = (await pickedFile.length()) / 1000;
      if (sizeInKb > widget.fileSize) {
        Fluttertoast.showToast(
          msg:
              'File size should not exceed ${(widget.fileSize / 1000).toStringAsFixed(2)}MB',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
      setState(() {
        choosedImage = pickedFile;
        uploadSlip.text = pickedFile.path.split('/').last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var image = '${AppConstants.imageUrl}${widget.accountImage}';
    return Scaffold(
      appBar: AppBar(
        title: bodyLargeText('Buy Pin', context),
        actions: [
          ///submit button
          TextButton(
              onPressed: submit,
              child: bodyLargeText('Submit', context,
                  color: Colors.white, fontWeight: FontWeight.bold))
        ],
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // titleLargeText('FinXpert Trading Solutions', context),
            // height20(),

            // ///account number
            // Row(
            //   children: [
            //     Expanded(
            //       child: bodyLargeText('Account Number:', context),
            //     ),
            //     height20(),
            //     Expanded(
            //       child: bodyLargeText('1234567890', context,
            //           useGradient: false, textAlign: TextAlign.end),
            //     ),
            //   ],
            // ),
            // height10(),

            // ///IFSC Code
            // Row(
            //   children: [
            //     Expanded(
            //       child: bodyLargeText('IFSC Code:', context),
            //     ),
            //     height20(),
            //     Expanded(
            //       child: bodyLargeText('SBIN0000000', context,
            //           useGradient: false, textAlign: TextAlign.end),
            //     ),
            //   ],
            // ),
            // height10(),

            // ///Branch Name
            // Row(
            //   children: [
            //     Expanded(
            //       child: bodyLargeText('Branch:', context),
            //     ),
            //     height20(),
            //     Expanded(
            //       child: bodyLargeText('SBI', context,
            //           useGradient: false, textAlign: TextAlign.end),
            //     ),
            //   ],
            // ),
            bodyLargeText(widget.accountInfo, context, maxLines: 10),
            height10(),
            if (widget.accountImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: image,
                placeholder: (context, url) => SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: appLogoColor.withOpacity(0.5)))),
                errorWidget: (context, url, error) =>
                    assetImages(Assets.noImage),
                cacheManager: CacheManager(Config(
                  "${AppConstants.packageID}_event_tickets_${image ?? ''}",
                  stalePeriod: const Duration(days: 7),
                  //one week cache period
                )),
              ),

            height20(),
            _buildForm(context, widget.packages),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Map<String, dynamic>> packages) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///name,user id, request pin type , not of pin , amount, transaction/Reference No.
          ///create form field for each and make it required and disable , add initial value to all
          bodyLargeText('Name', context),
          height5(),
          TextFormField(
            initialValue: sl.get<AuthProvider>().userData.customerName ?? '',
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          height10(),
          bodyLargeText('User ID', context),
          height5(),
          TextFormField(
            initialValue: sl.get<AuthProvider>().userData.username ?? '',
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'User ID',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          height10(),
          bodyLargeText('Request Pin Type', context),
          height5(),

          ///textfield with dropdown button to select package type

          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white54)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                isDense: true,
                items: packages
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: bodyLargeText(e['name'] ?? '', context,
                              useGradient: false, color: Colors.black),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedPackage = value;
                  amountController.text =
                      (double.tryParse(value?['amount'] ?? '0') ?? 0.0)
                          .toStringAsFixed(2);
                  max = int.tryParse(value?['max'] ?? '1') ?? 1;
                  setState(() {});
                },
                hint: bodyLargeText('Select Pin Type', context,
                    useGradient: false, color: Colors.white70),
                value: selectedPackage,
                selectedItemBuilder: (context) => packages
                    .map((e) => bodyLargeText(
                          e['name'] ?? '',
                          context,
                          useGradient: false,
                        ))
                    .toList(),
                // Expanded(
                //   child: TextFormField(
                //     enabled: false,
                //     style: const TextStyle(color: Colors.white),
                //     textInputAction: TextInputAction.next,
                //     decoration: const InputDecoration(
                //       hintText: 'Select Pin Type',
                //       hintStyle: TextStyle(color: Colors.white70),
                //     ),
                //   ),
                // ),
              ),
            ),
          ),
          height10(),
          bodyLargeText('No. of Pin', context),
          height5(),
          TextFormField(
            enabled: selectedPackage != null,
            controller: pinCountController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                hintText: 'No. of Pin',
                hintStyle: const TextStyle(color: Colors.white70),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    width10(),
                    Center(child: capText('Max($max)', context)),
                    width10(),
                  ],
                )),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of pins';
              }
              if ((int.tryParse(value) ?? 0) > max) {
                return 'You can only buy $max pins';
              }
              return null;
            },
          ),
          height10(),
          bodyLargeText('Amount', context),
          height5(),
          TextFormField(
            controller: amountController,
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Amount',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the amount';
              }
              return null;
            },
          ),
          height10(),
          bodyLargeText('Transaction/Reference No.', context),
          height5(),
          TextFormField(
            controller: transactionController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Transaction/Reference No.',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the transaction/reference number';
              }
              return null;
            },
          ),

          height10(),

          ///Sender Account Name
          bodyLargeText('Sender Account Name', context),
          height5(),
          TextFormField(
            controller: acName,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Sender Account Name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the sender account name';
              }
              return null;
            },
          ),
          height10(),

          ///Sender Account Number
          bodyLargeText('Sender Account Number', context),
          height5(),
          TextFormField(
            controller: acNumber,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Sender Account Number',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the sender account number';
              }
              return null;
            },
          ),

          ///Sender Bank Name
          height10(),
          bodyLargeText('Sender Bank Name', context),
          height5(),
          TextFormField(
            controller: bcName,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Sender Bank Name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the sender bank name';
              }
              return null;
            },
          ),
          height10(),
          bodyLargeText('Upload Transfer Slip', context),
          height5(),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: uploadSlip,
                  onTap: uploadImage,
                  enabled: false,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Upload Transfer Slip',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              height20(),
              IconButton(
                  onPressed: () {
                    if (choosedImage != null) {
                      choosedImage = null;
                      uploadSlip.clear();
                      setState(() {});
                    } else {
                      uploadImage();
                    }
                  },
                  icon: Icon(
                    choosedImage == null
                        ? Icons.upload_file
                        : Icons.delete_forever,
                    color: choosedImage == null ? Colors.white : Colors.red,
                  ))
            ],
          )
        ],
      ),
    );
  }
}
