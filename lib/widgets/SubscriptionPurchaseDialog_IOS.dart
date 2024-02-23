import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/database/functions.dart';
import '/utils/default_logger.dart';
import 'package:share_plus/share_plus.dart';
import '../database/model/response/subscription_package_model.dart';
import '../utils/my_logger.dart';
import '/providers/auth_provider.dart';
import '/providers/subscription_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class SubscriptionPurchaseDialogIOS extends StatefulWidget {
  const SubscriptionPurchaseDialogIOS({
    super.key,
  });

  @override
  State<SubscriptionPurchaseDialogIOS> createState() =>
      _SubscriptionPurchaseDialogIOSState();
}

class _SubscriptionPurchaseDialogIOSState
    extends State<SubscriptionPurchaseDialogIOS>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController animationController;
  TextEditingController typeController = TextEditingController();
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    super.initState();
    getPendingPurchases().then((value) => completePurchases(value));

    /// register app life cycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.i('didChangeAppLifecycleState: $state');
    _handleAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _handleAppLifecycleState(AppLifecycleState state) async {}

  completePurchases(List<PurchaseDetails> purchases) {
    try {
      for (var element in purchases) {
        logger.i('completePurchases: ${element.productID}');
        // removePendingPurchase(element);
        InAppPurchase.instance
            .completePurchase(AppStorePurchaseDetails(
                productID: element.productID,
                verificationData: element.verificationData,
                transactionDate: element.transactionDate,
                skPaymentTransaction: SKPaymentTransactionWrapper(
                    payment:
                        SKPaymentWrapper(productIdentifier: element.productID),
                    transactionState:
                        SKPaymentTransactionStateWrapper.purchasing),
                status: element.status))
            .then((value) => removePendingPurchase(element));
      }
    } catch (e) {
      logger.e(' failed: ', error: e, tag: 'completePurchases');
    }
  }

  @override
  void dispose() {
    var provider = sl.get<SubscriptionProvider>();
    provider.selectedPaymentTypeKey = null;
    provider.selectedPackage = null;
    provider.couponVerified = null;
    provider.voucherCodeController.clear();
    provider.typeController.clear();

    ///remove app life cycle
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              color: bColor(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: titleLargeText(
                                  'Get access to all features', context,
                                  fontSize: 32, useGradient: true),
                            ),
                            width30(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        height20(),
                        // Row(
                        //   children: [
                        //     const Icon(Icons.check_rounded, color: appLogoColor),
                        //     width10(),
                        //     bodyLargeText(
                        //         'Unlimited access to all courses', context,
                        //         fontWeight: FontWeight.w500,
                        //         useGradient: false),
                        //   ],
                        // ),
                        // height10(),
                        // Row(
                        //   children: [
                        //     const Icon(Icons.check_rounded, color: appLogoColor),
                        //     width10(),
                        //     Expanded(
                        //       child: bodyLargeText(
                        //           'You can withdraw incomes to your bank account whenever you want.',
                        //           context,
                        //           fontWeight: FontWeight.w500,
                        //           useGradient: false),
                        //     ),
                        //   ],
                        // ),
                        // height10(),
                        // Row(
                        //   children: [
                        //     const Icon(Icons.check_rounded, color: appLogoColor),
                        //     width10(),
                        //     bodyLargeText(
                        //         'Unlimited access to ', context,
                        //         fontWeight: FontWeight.w500,
                        //         useGradient: false),
                        //   ],
                        // ),
                        // height20(),

                        ///payment type
                        // bodyLargeText('Payment Type', context,
                        //     fontWeight: FontWeight.w500,
                        //     useGradient: false,
                        //     fontSize: 16),
                        // height10(),
                        // Row(
                        //   children: <Widget>[
                        //     Expanded(
                        //       child: TextFormField(
                        //         readOnly: true,
                        //         controller: provider.typeController,
                        //         onTap: () {
                        //           showModalBottomSheet(
                        //             context: context,
                        //             backgroundColor: Colors.transparent,
                        //             barrierColor:
                        //                 const Color.fromARGB(36, 202, 202, 202),
                        //             enableDrag: true,
                        //             isScrollControlled: true,
                        //             builder: (context) =>
                        //                 SelectPaymentMethodDialog(
                        //                     packages: provider.paymentTypes,
                        //                     selected: provider
                        //                                 .selectedPaymentTypeKey !=
                        //                             null
                        //                         ? MapEntry(
                        //                             provider
                        //                                 .selectedPaymentTypeKey!,
                        //                             provider.paymentTypes[provider
                        //                                 .selectedPaymentTypeKey!])
                        //                         : null,
                        //                     onTap: (value) {
                        //                       Get.back();
                        //                       if (provider
                        //                               .selectedPaymentTypeKey !=
                        //                           value.key) {
                        //                         provider.voucherCodeController
                        //                             .clear();
                        //                       }
                        //                       provider.setSelectedTypeKey(
                        //                           value.key);
                        //                       provider.typeController.text =
                        //                           value.value;
                        //                     }),
                        //             // buildDraggableScrollableSheet(provider),
                        //           );
                        //         },
                        //         enabled: true,
                        //         cursorColor: Colors.white,
                        //         style: const TextStyle(color: Colors.white),
                        //         decoration: InputDecoration(
                        //             hintText: 'Select method',
                        //             hintStyle: const TextStyle(color: Colors.white70),
                        //             helperText: provider
                        //                         .selectedPaymentTypeKey ==
                        //                     'MCC Commission Wallet'
                        //                 ? '${provider.typeController.text}: $currencyIcon${provider.commissionMBal.toStringAsFixed(2)}'
                        //                 : provider.selectedPaymentTypeKey ==
                        //                         'NG Commission Wallet'
                        //                     ? '${provider.typeController.text}: $currencyIcon${provider.commissionNBal.toStringAsFixed(2)}'
                        //                     : provider.selectedPaymentTypeKey ==
                        //                             'Amgen Wallet'
                        //                         ? '${provider.typeController.text}: $currencyIcon${provider.amgenBal.toStringAsFixed(2)}'
                        //                         : provider.selectedPaymentTypeKey ==
                        //                                 'NG Cash Wallet'
                        //                             ? '${provider.typeController.text}: $currencyIcon${provider.cashNBal.toStringAsFixed(2)}'
                        //                             : null,
                        //             helperStyle: const TextStyle(
                        //                 color: Colors.red,
                        //                 fontWeight: FontWeight.bold),
                        //             border: OutlineInputBorder(
                        //                 borderSide:
                        //                     const BorderSide(color: Colors.white),
                        //                 borderRadius: BorderRadius.circular(5)),
                        //             enabledBorder: OutlineInputBorder(
                        //                 borderSide:
                        //                     const BorderSide(color: Colors.white),
                        //                 borderRadius: BorderRadius.circular(5)),
                        //             focusedBorder: OutlineInputBorder(
                        //                 borderSide:
                        //                     const BorderSide(color: Colors.white),
                        //                 borderRadius: BorderRadius.circular(5)),
                        //             suffixIcon: const Icon(
                        //                 Icons.arrow_drop_down_circle_outlined,
                        //                 color: Colors.white)),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  /*
                  //coupon code field
                  if (provider.selectedPaymentTypeKey != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  controller: provider.voucherCodeController,
                                  readOnly: provider.couponVerified != null,
                                  cursorColor: Colors.white,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText:
                                          provider.selectedPaymentTypeKey ==
                                                  'E-Pin'
                                              ? 'Enter voucher code'
                                              : 'Enter MCC Coupon Code',
                                      hintStyle: const TextStyle(
                                          color: Colors.white70),
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      suffixIcon:
                                          buildCouponFieldSuffix(provider)),
                                ),
                              ),
                            ],
                          ),
                          height10(5),
                          if (provider.couponVerified != null)
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: 'Coupon Applied: ',
                                  style: TextStyle(color: Colors.green)),
                              TextSpan(
                                  text: provider.voucherCodeController.text,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ])),
                          height10(16),
                        ],
                      ),
                    ),

                  //discount note
                  if (1 == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          capText(
                            provider.discount_note!,
                            context,
                            useGradient: true,
                            fontWeight: FontWeight.w500,
                            textAlign: TextAlign.center,
                          ),
                          height10(16),
                        ],
                      ),
                    ),
*/
                  //packs
                  Expanded(
                    child: _PacksList(
                      packages: provider.packages.map((e) {
                        // e.joiningId = 'price_1NxB8oIXIttwdQOUFWT48973';
                        return e;
                      }).toList(),
                      selected: provider.selectedPackage,
                      onTap: (value) {
                        // provider.setSelectedPackage(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PacksList extends StatefulWidget {
  const _PacksList(
      {super.key, required this.packages, this.selected, this.onTap});
  final List<SubscriptionPackage> packages;
  final SubscriptionPackage? selected;
  final Function(MapEntry)? onTap;

  @override
  State<_PacksList> createState() => __PacksListState();
}

class __PacksListState extends State<_PacksList> {
  final SubscriptionProvider provider = sl.get<SubscriptionProvider>();
  final userData = sl.get<AuthProvider>().userData;
  bool loadingMyProducts = true;
  List<Pack> myPacks = [];
  final String tag = '_PacksList';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  // List<ProductDetails> _pendingPurchases = <ProductDetails>[];
  // List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
//////////////////////////////  idsRespectToAppStoreConnect  //////////////////////////////
  Map<String, String> idsRespectToAppStoreConnect = {
    'price_1NxBB6IXIttwdQOU5NNaxleT': 'monthly_1',
    'price_1NxBA1IXIttwdQOUXvCCJJg1': 'months_3',
    'price_1NxB8oIXIttwdQOUFWT48973': 'yearly_1',
    'price_1NvdgeIXIttwdQOUkqofczRS': 'joining_fee',
    'price_1NxptvIXIttwdQOUkY1B4rSC': 'd_joining_fee',
  };

  @override
  void initState() {
    ///add listener
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
        (List<PurchaseDetails> purchaseDetailsList) async {
      _listenToPurchaseUpdated(purchaseDetailsList);
      for (var e in purchaseDetailsList) {
        await savePendingPurchase(e);
      }
      logger.f(
        '_subscription listener purchaseUpdated',
        tag: tag,
        error: ' \nproducts: ${purchaseDetailsList.map((e) => e.productID)}\n'
            'status: ${purchaseDetailsList.map((e) => e.status)} \n'
            'pendingCompletePurchase: ${purchaseDetailsList.map((e) => e.pendingCompletePurchase)}\n'
            '_pendingPurchases: ${provider.pendingPurchases.map((e) => e.id)}\n'
            '_purchase: ${provider.purchases.map((e) => e.productID)}',
      );
    }, onDone: () {
      logger.f(
        '_subscription listener purchaseUpdated',
        tag: tag,
        error: 'onDone',
      );
      if (provider.pendingPurchases.isEmpty && _purchasePending) {
        _purchasePending = false;
        setState(() {});
      }
      _subscription.cancel();
    }, onError: (Object error) {
      if (provider.pendingPurchases.isEmpty && _purchasePending) {
        _purchasePending = false;
        setState(() {});
      }
      logger.e(
        '_subscription listener purchaseUpdated onError',
        tag: tag,
        error: error,
        stackTrace: StackTrace.current,
      );
    });

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadProducts());
  }

  Future<void> loadProducts() async {
    myPacks.clear();
    for (var e in widget.packages) {
      try {
        Pack? pack = await _getPack([
          {
            'package_id': e.packageId ?? '',
            'product_id': 'price_1NvdgeIXIttwdQOUkqofczRS',
            // 'product_id': e.joiningId ?? '',
            'sale_type': e.sale_type ?? '',
            'coupon_code': '',
            'coupon_discount': '',
          },
          {
            'package_id': e.packageId ?? '',
            'product_id': 'price_1NxptvIXIttwdQOUkY1B4rSC',
            // 'product_id': e.d_joining_id ?? '',
            'sale_type': e.sale_type ?? '',
            'coupon_code': '',
            'coupon_discount': '',
          },
          {
            'package_id': e.packageId ?? '',
            'product_id': e.productId ?? '',
            'sale_type': e.sale_type ?? '',
            'coupon_code': '',
            'coupon_discount': '',
          }
        ]);
        if (pack != null) myPacks.add(pack);
      } catch (e) {
        logger.e('loadProducts failed: ', tag: tag, error: e);
      }
    }
    logger.i(
      'loadProducts mypacks length: ${myPacks.map((e) => e.products.map((e) => e.storeId))}',
      tag: 'MyPacks',
    );
    if (myPacks.isNotEmpty) await getStoreProducts();
    setState(() => loadingMyProducts = false);
  }

  Future<Pack?> _getPack(List<Map<String, dynamic>> ids) async {
    var packIds = ids
        .where((element) =>
            element['product_id'] != null &&
            element['product_id'].toString().isNotEmpty &&
            element['product_id'] != '-')
        .toList();
    print('packIds to get by purchase: $packIds');
    Pack pack = Pack(products: []);
    for (var data in packIds) {
      String packId = data['product_id'];
      late PurchaseType purchaseType;
      late ProductType productType;
      late String id;
      late String storeId;
      String? image;
      String? price;
      String? description;
      String? title;

      switch (packId) {
        case 'price_1NxBB6IXIttwdQOU5NNaxleT':
          purchaseType = PurchaseType.consumable;
          productType = ProductType.subscription;
          break;
        case 'price_1NxBA1IXIttwdQOUXvCCJJg1':
          purchaseType = PurchaseType.consumable;
          productType = ProductType.subscription;
          break;
        case 'price_1NxB8oIXIttwdQOUFWT48973':
          purchaseType = PurchaseType.consumable;
          productType = ProductType.subscription;
          break;
        case 'price_1NvdgeIXIttwdQOUkqofczRS':
          purchaseType = PurchaseType.consumable;
          productType = ProductType.joining;
          break;
        case 'price_1NxptvIXIttwdQOUkY1B4rSC':
          purchaseType = PurchaseType.consumable;
          productType = ProductType.dJoining;
          break;
      }
      storeId = idsRespectToAppStoreConnect[packId]!;
      id = packId;
      image = 'https://picsum.photos/250?image=9';
      price = 'pack.amount';
      description = 'pack.description';
      title = 'pack.name';

      pack.products.add(MyProducts(
        purchaseType: purchaseType,
        productType: productType,
        id: id,
        storeId: storeId,
        title: title,
        description: description,
        image: image,
        price: price,
        data: data,
      ));
    }
    logger.i('pack.products: ${pack.products.map((e) => e.storeId)}', tag: tag);
    return pack;
  }

  Future<void> getStoreProducts() async {
    /// check if available
    final bool isAvailable = await _inAppPurchase.isAvailable();
    logger.i('getStoreProducts isAvailable: $isAvailable', tag: 'isAvailable');
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        provider.purchases.clear();
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = false);

    ///setDelegate
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.showPriceConsentIfNeeded();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ///get products
    List<String> _ids = [];
    for (var pack in myPacks) {
      for (var myProduct in pack.products) {
        _ids.add(myProduct.storeId);
      }
    }
    logger.i('getStoreProducts _ids: $_ids', tag: 'ids');
    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_ids.toSet());
    logger.i(
      productDetailResponse.notFoundIDs,
      error:
          'found: ${productDetailResponse.productDetails.map((e) => e.price)}\n'
          'not-found: ${productDetailResponse.notFoundIDs}\n'
          'error:${productDetailResponse.error}',
      tag: 'productDetailResponse',
    );
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        provider.purchases.clear();
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }
    try {
      for (var detail in productDetailResponse.productDetails) {
        for (var element in myPacks) {
          for (var e in element.products) {
            if (e.storeId == detail.id) e.productDetails = detail;
          }
        }

        // _inAppPurchase.completePurchase(AppStorePurchaseDetails(
        //     productID: e.storeId,
        //     verificationData: PurchaseVerificationData(
        //         localVerificationData: '',
        //         serverVerificationData: '',
        //         source: ''),
        //     transactionDate: DateTime.now.toString(),
        //     status: PurchaseStatus.canceled,
        //     skPaymentTransaction: SKPaymentTransactionWrapper(
        //         payment: SKPaymentWrapper(productIdentifier: detail.id),
        //         transactionState:
        //             SKPaymentTransactionStateWrapper.unspecified)));
        // _inAppPurchase
        //     .queryProductDetails({detail.id}).then((value) async {
        //   logger.i(
        //       'myPacks productDetailResponse.productDetails -> start: ${myPacks.map((e) => e.products.map((e) => e.productDetails?.id))}',
        //       tag: tag);
        //   value.productDetails.map((e) => _inAppPurchase.completePurchase(
        //       AppStorePurchaseDetails(
        //           productID: e.id,
        //           verificationData: PurchaseVerificationData(
        //               localVerificationData: '',
        //               serverVerificationData: '',
        //               source: ''),
        //           transactionDate: DateTime.now.toString(),
        //           status: PurchaseStatus.canceled,
        //           skPaymentTransaction: SKPaymentTransactionWrapper(
        //               payment: SKPaymentWrapper(productIdentifier: e.id),
        //               transactionState: SKPaymentTransactionStateWrapper
        //                   .unspecified))));
        // });
      }
      logger.i(
          'setting up product details in each pack -> end: ${myPacks.map((e) => e.products.map((e) => e.productDetails?.id))}',
          tag: 'productDetailResponse');
    } catch (e) {
      logger.e(
        'productDetailResponse.productDetails:',
        tag: tag,
        error: e,
        stackTrace: StackTrace.current,
      );
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        provider.purchases.clear();
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    // final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      // _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel().then((value) => logger.i(
        '_subscription canceled: ${_subscription.isPaused}',
        tag: tag,
        error: 'dispose'));
    // provider._purchases = <PurchaseDetails>[];
    // provider._pendingPurchases = <ProductDetails>[];
    provider.purchases.clear();
    provider.pendingPurchases.clear();
    if (mounted) {
      if (provider.purchases.isNotEmpty) {
        provider.purchases.map((e) => _inAppPurchase.completePurchase(e));
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = <Widget>[];

    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            _buildConnectionCheckTile(),

            ///apply coupon text field with button
            _buildCouponTextField(),
            _buildProductList(),
            // _buildConsumableBox(),
            // _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(child: capText(_queryProductError!, context)));
    }

    ///if purchasePending
    if (_purchasePending) {
      stack.add(
        Stack(
          children: const <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }
    return Column(children: [
      // bodyLargeText(widget.packages.length.toString(), context),

      /// UI
      Expanded(child: Stack(children: stack))
    ]);
  }

  Widget _buildCouponTextField() {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: provider.voucherCodeController,
                      readOnly: provider.couponVerified != null,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: provider.selectedPaymentTypeKey == 'E-Pin'
                            ? 'Enter voucher code'
                            : 'Enter MCC Coupon Code',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5)),
                        // suffixIcon: buildCouponFieldSuffix(provider)
                      ),
                    ),
                  ),
                  width10(),
                  buildCouponFieldSuffix(provider),
                ],
              ),
              height10(5),
              if (provider.couponVerified != null &&
                  provider.couponVerified == true)
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                      text: 'Coupon Applied: ',
                      style: TextStyle(color: Colors.green)),
                  TextSpan(
                      text: provider.voucherCodeController.text,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ])),
              height10(16),
            ],
          ),
        );
      },
    );
  }

  Widget buildCouponFieldSuffix(SubscriptionProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: provider.loadingVerifyCoupon ? 60 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
            colors: textGradiantColors.map((e) => e.withOpacity(0.4)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: TextButton(
        onPressed: provider.loadingVerifyCoupon
            ? null
            : () => _handleCoupuon(provider),
        child: provider.loadingVerifyCoupon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                  ),
                ],
              )
            : Text(
                provider.couponVerified == null ||
                        provider.couponVerified == false
                    ? 'Check'
                    : 'Clear',
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  _handleCoupuon(SubscriptionProvider provider) {
    FocusScope.of(context).unfocus();
    bool couponAdded =
        provider.couponVerified != null && provider.couponVerified == true;
    if (couponAdded) {
      provider.voucherCodeController.clear();
      provider.couponVerified = null;
    } else {
      if (provider.voucherCodeController.text.isNotEmpty) {
        provider
            .verifyCoupon(provider.voucherCodeController.text)
            .then((value) => provider.couponVerified = true);
      } else {
        Fluttertoast.showToast(msg: 'Please enter coupon code');
      }
    }
    setState(() {});
  }

//////////////////////////////  _buildConnectionCheckTile  //////////////////////////////
  Widget _buildConnectionCheckTile() {
    if (_loading) {
      return SizedBox(
          height: 100,
          child: Center(child: bodyMedText('Connect to store...', context)));
    } else {
      return const Card();
    }
    // final Widget storeHeader = ListTile(
    //   leading: Icon(_isAvailable ? Icons.check : Icons.block,
    //       color: _isAvailable
    //           ? Colors.green
    //           : ThemeData.light().colorScheme.error),
    //   title: bodyMedText(
    //       'The store is ${_isAvailable ? 'available' : 'unavailable'}.',
    //       context),
    // );
    final List<Widget> children = <Widget>[
      // storeHeader,
    ];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        Container(
          height: 300,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /// ui for store not available
              titleLargeText('Store unavailable', context,
                  style: TextStyle(
                      color: ThemeData.light().colorScheme.error,
                      fontSize: 32)),
              height20(),
              titleLargeText(
                'Storefront is unavailable or stopped. Please try again later.',
                context,
                textAlign: TextAlign.center,
              ),
              height30(),
            ],
          ),
        )
      ]);
    }
    return Column(children: children);
  }

//////////////////////////////  _buildProductList  //////////////////////////////
  Widget _buildProductList() {
    /// if loading products
    if (loadingMyProducts && !_loading) {
      return SizedBox(
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(color: Colors.white),
            width20(),
            bodyMedText('Loading products...', context),
          ],
        ),
      );
    }

    /// if store not available
    if (!_isAvailable && !loadingMyProducts) {
      return Container(
        height: 300,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// ui for store not available
            titleLargeText('Store unavailable', context,
                style: TextStyle(
                    color: ThemeData.light().colorScheme.error, fontSize: 32)),
            height20(),
            titleLargeText(
              'Storefront is unavailable or stopped. Please try again later.',
              context,
              textAlign: TextAlign.center,
            ),
            height30(),
          ],
        ),
      );
    }

    /// if products found
    // ListTile productHeader =
    //     ListTile(title: bodyMedText('Products for Sale', context));
    final List<Widget> productList = <Widget>[];

    /// if products not found

    if (_notFoundIds.isNotEmpty & kDebugMode && !loadingMyProducts) {
      productList.add(ListTile(
          title: bodyMedText('[${_notFoundIds.join(", ")}] not found', context,
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: bodyMedText(
              'This app needs special configuration to run. Please see example/README.md for instructions.',
              context)));
    }
    if (_products.isEmpty && !loadingMyProducts) {
      return Container(
        height: 300,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// ui for store not available
            titleLargeText('Products  not available at this time', context,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ThemeData.light().colorScheme.error,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            height20(),
            titleLargeText(
              'Please try again later\nOr\ncontact support',
              context,
              lineHeight: 1.5,
              textAlign: TextAlign.center,
            ),
            height30(),
          ],
        ),
      );
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.

    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            provider.purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    ///complete purchase
    for (var element in myPacks) {
      for (var e in element.products) {
        try {
          _inAppPurchase.restorePurchases();
        } catch (e) {
          logger.e('completePurchase failed: ${e.toString()}', tag: tag);
        }
      }
    }

    ///build product list

    productList
        .addAll(myPacks.map((pack) => _buildProductListTile(pack, purchases)));
    // productList.addAll(_products.map(
    //   (ProductDetails productDetail) {
    //     final PurchaseDetails? previousPurchase = purchases[productDetail.id];
    //     final ProductDetails productDetails = productDetail;
    //     return ListTile(
    //       title: bodyMedText(productDetail.title, context),
    //       subtitle: bodyMedText(productDetail.description, context),
    //       trailing: previousPurchase != null && Platform.isIOS
    //           ? IconButton(
    //               onPressed: () => confirmPriceChange(context),
    //               icon: const Icon(Icons.upgrade))
    //           : TextButton(
    //               style: TextButton.styleFrom(
    //                 backgroundColor: Colors.green[800],
    //                 foregroundColor: Colors.white,
    //               ),
    //               onPressed: () => _purchase(productDetails),
    //               child: Text(productDetails.price),
    //             ),
    //     );
    //   },
    // ));

    return Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
                // productHeader,
                const Divider(color: Colors.white),
              ] +
              productList,
        ));
  }

//////////////////////////////  _buildProductListTile  //////////////////////////////
  Widget _buildProductListTile(
      Pack pack, Map<String, PurchaseDetails> purchases) {
    var products = pack.products
        .where((element) => element.productDetails != null)
        .toList();

    Widget child = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white70, width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        ...products
            .map((e) => _buildProductListTileChild(e, purchases))
            .toList(),
        if (products.length > 1)
          Column(
            children: [
              // height10(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.white),
              ),
              ListTile(
                title: bodyLargeText('Buy Togther', context),
                subtitle: capText(
                    '${products.mapIndexed((i, e) => '${e.productDetails!.price}${i < products.length - 1 ? " + " : ''}').join()} = ',
                    context),
                trailing: FilledButton(
                    style:
                        FilledButton.styleFrom(backgroundColor: appLogoColor),
                    onPressed: () => _purchaseMultiple(
                        products.map((e) => e.productDetails!).toList()),
                    child: bodyMedText(
                        '${products.first.productDetails!.currencySymbol} ${products.map<double>((e) => e.productDetails!.rawPrice).fold(0, (previousValue, element) => (previousValue + element).toInt())} Buy',
                        context)),
              ),
            ],
          ),
      ]),
    );
    return child;
    return ExpansionTile(
      title: Text(
        pack.title ?? '',
      ),
      subtitle: Text(
        pack.description ?? '',
      ),
      children: pack.products
          .where((element) => element.productDetails != null)
          .map((e) => _buildProductListTileChild(e, purchases))
          .toList(),
    );
  }

//////////////////////////////  _buildProductListTileChild  //////////////////////////////
  Widget _buildProductListTileChild(
      MyProducts myProduct, Map<String, PurchaseDetails> purchases) {
    final PurchaseDetails? previousPurchase = purchases[myProduct.storeId];
    // logger.w('_buildProductListTileChild: ${myProduct.storeId}', tag: tag);
    final ProductDetails productDetails = myProduct.productDetails!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: bodyLargeText(myProduct.productDetails!.title, context),
      subtitle: bodyMedText(
          '${myProduct.productDetails!.description}'
          '\n${myProduct.productType.name}',
          context),
      trailing:
          //  previousPurchase != null && Platform.isIOS
          //     ? IconButton(
          //         onPressed: () => confirmPriceChange(context),
          //         icon: const Icon(Icons.upgrade))
          //     :
          TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () => _purchase(productDetails),
        child: Text(productDetails.price),
      ),
    );
  }

//////////////////////////////  _listenToPurchaseUpdated  //////////////////////////////
  void _purchase(ProductDetails productDetails) async {
    try {
      late PurchaseParam purchaseParam;

      ///ios
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: userData.username ?? '',
      );

      // if (productDetails.id == _kConsumableId) {
      //   _inAppPurchase.buyConsumable(
      //       purchaseParam: purchaseParam,
      //       autoConsume: _kAutoConsume);
      // }
      // else {
      provider.pendingPurchases.clear();
      provider.setPendingPurchase(productDetails);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      // }
    } on PlatformException catch (e) {
      if (e.message == null) {
      } else if (e.message!.contains('BillingResponse.ITEM_ALREADY_OWNED')) {
        Fluttertoast.showToast(msg: 'You already own this item');
      } else if (e.message!.contains('BillingResponse.USER_CANCELED')) {
        Fluttertoast.showToast(msg: 'Purchase canceled');
      } else {
        Fluttertoast.showToast(msg: 'Purchase failed');
      }
      logger.e('purchaseMultiple: ${e.toString()}', tag: tag);
    } catch (e) {
      logger.e('purchaseMultiple: ${e.toString()}', tag: tag);
    }
  }

//////////////////////////////  _purchaseMultiple  //////////////////////////////
  Future<void> _purchaseMultiple(List<ProductDetails> products) async {
    try {
      final ProductDetails product1 = products[0];
      final ProductDetails product2 = products[1];

      final PurchaseParam param1 = PurchaseParam(productDetails: product1);
      final PurchaseParam param2 = PurchaseParam(productDetails: product2);

      for (var element in [product1, product2]) {
        provider.setPendingPurchase(element);

        ///testing
        /*
        SKProductDiscountWrapper discount = SKProductDiscountWrapper(
          price: ' 0.99',
          priceLocale: SKPriceLocaleWrapper(
            countryCode: 'US',
            currencyCode: 'USD',
            currencySymbol: '\$',
          ),
          numberOfPeriods: 1,
          subscriptionPeriod: SKProductSubscriptionPeriodWrapper(
            numberOfUnits: 1,
            unit: SKSubscriptionPeriodUnit.month,
          ),
          identifier: '',
          paymentMode: SKProductDiscountPaymentMode.payAsYouGo,
          type: SKProductDiscountType.introductory,
        );

        SKProductWrapper productWrapper = SKProductWrapper(
          productIdentifier: element.id,
          localizedTitle: element.title,
          localizedDescription: element.description,
          priceLocale: SKPriceLocaleWrapper(
            countryCode: element.currencyCode,
            currencyCode: element.currencyCode,
            currencySymbol: element.currencySymbol,
          ),
          price: element.rawPrice.toString(),
        );

        SKPaymentWrapper paymentWrapper = SKPaymentWrapper(
          productIdentifier: element.id,
          quantity: 1,
          applicationUsername: userData.username ?? '',
          requestData: '',
          simulatesAskToBuyInSandbox: false,
          paymentDiscount: SKPaymentDiscountWrapper(
            identifier: element.id,
            keyIdentifier: '',
            nonce: '',
            signature: '',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
          
        );
     
     */

        SKPaymentQueueWrapper paymentQueueWrapper = SKPaymentQueueWrapper();
        paymentQueueWrapper
            .addPayment(SKPaymentWrapper(
              productIdentifier: element.id,
              quantity: 1,
              applicationUsername: userData.username ?? '',
              requestData: '',
              simulatesAskToBuyInSandbox: false,
              paymentDiscount: SKPaymentDiscountWrapper(
                identifier: element.id,
                keyIdentifier: element.id,
                nonce: userData.username ?? '',
                signature: userData.username ?? '',
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            ))
            .then((value) => logger.i('addPayment: ', tag: tag))
            .onError((error, stackTrace) => logger.e(
                'addPayment: ${error.toString()}',
                tag: tag,
                error: error,
                stackTrace: stackTrace));
      }
      // Initiate purchase for the first product
      final bool purchase1 =
          await InAppPurchase.instance.buyNonConsumable(purchaseParam: param1);
      logger.w('purchase1 ---: $purchase1');
      if (purchase1) {
        // First product purchased successfully; now purchase the second product
        final bool purchase2 = await InAppPurchase.instance
            .buyNonConsumable(purchaseParam: param2);
        logger.w('purchase2 ---: $purchase2');
        if (purchase2) {
          // Both products have been successfully purchased together
        } else {
          // Handle failure to purchase the second product
        }
      } else {
        // Handle failure to purchase the first product
      }
    } on PlatformException catch (e) {
      if (e.message == null) {
      } else if (e.message!.contains('BillingResponse.ITEM_ALREADY_OWNED')) {
        Fluttertoast.showToast(msg: 'You already own this item');
      } else if (e.message!.contains('BillingResponse.USER_CANCELED')) {
        Fluttertoast.showToast(msg: 'Purchase canceled');
      } else {
        Fluttertoast.showToast(msg: 'Purchase failed');
      }
      logger.e('purchaseMultiple: ${e.toString()}', tag: tag);
    } catch (e) {
      logger.e('purchaseMultiple: ${e.toString()}', tag: tag);
    }
  }

//////////////////////////////  _buildConsumableBox  //////////////////////////////
  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
    }
    // if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
    //   return const Card();
    // }
    const ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      const Divider(),
      GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        children: tokens,
      )
    ]));
  }

//////////////////////////////  _buildRestoreButton  //////////////////////////////
  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }

//////////////////////////// confirmPriceChange  ////////////////////////////
  Future<void> confirmPriceChange(BuildContext context) async {
    // Price changes for Android are not handled by the application, but are
    // instead handled by the Play Store. See
    // https://developer.android.com/google/play/billing/price-changes for more
    // information on price changes on Android.
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

//////////////////////////////  consume  //////////////////////////////
  Future<void> consume(String id) async {
    // await ConsumableStore.consume(id);
    // final List<String> consumables = await ConsumableStore.load();
    // setState(() {
    //   _consumables = consumables;
    // });
  }
//////////////////////////////  showPendingUI  //////////////////////////////
  void showPendingUI() {
    if (!_purchasePending) {
      // Get.back();
      setState(() => _purchasePending = true);
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => _PurchasePrecessSheet(myPacks: myPacks));
    }
  }

//////////////////////////////  handleError  //////////////////////////////
  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

//////////////////////////////  _verifyPurchase  //////////////////////////////
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

//////////////////////////////  deliverProduct  //////////////////////////////
  Future<void> deliverProduct(PurchaseDetails purchaseDetails,
      [MyProducts? myProducts]) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    // if (purchaseDetails.productID == _kConsumableId) {
    //   await ConsumableStore.save(purchaseDetails.purchaseID!);
    //   final List<String> consumables = await ConsumableStore.load();
    //   setState(() {
    //     _purchasePending = false;
    //     _consumables = consumables;
    //   });
    // } else {
    if (myProducts != null) {
      try {
        successLog(
            'deliverProduct: ${myProducts.productType.name}',
            jsonEncode({
              'purchaseID': purchaseDetails.purchaseID ?? '',
              'productID': purchaseDetails.productID,
              'status': purchaseDetails.status.name,
              'source': purchaseDetails.verificationData.source,
              'transactionDate': purchaseDetails.transactionDate ?? '',
            }));
        _handleApiSubmittion(purchaseDetails, myProducts);
      } catch (e) {
        logger.e('deliverProduct _handleApiSubmittion error: ${e.toString()}',
            tag: tag);
      }
    }
    setState(() {
      provider.setPurchases(purchaseDetails);
      _purchasePending = false;
    });
    var productDetail = provider.pendingPurchases
        .firstWhere((element) => element.id == purchaseDetails.productID);

    provider.setPendingPurchase(productDetail, remove: true);
    printPurchaseDetail(
      purchaseDetails,
      'PurchaseStatus deliverProduct: ${provider.pendingPurchases.length} ->  ${provider.purchases.length}',
    );
    // }
  }

  ////////////////////////////// _handleApiSubmittion  //////////////////////////////
  Future<void> _handleApiSubmittion(
      PurchaseDetails purchaseDetails, MyProducts myProducts) async {
    switch (myProducts.productType) {
      case ProductType.joining:
        provider.submitJoinigPackageIosPurchase({
          'package_id': myProducts.data['package_id'] ?? '',
          'sale_type': myProducts.data['sale_type'] ?? '',
          'coupon_code': '',
          'coupon_discount': '',
          'tx_id': purchaseDetails.purchaseID ?? '',
          'username': userData.username ?? '',
        });
        break;
      case ProductType.dJoining:
        break;
      case ProductType.subscription:
        provider.submitSubscriptionPackageIosPurchase({
          'package_id': myProducts.data['package_id'] ?? '',
          'sale_type': myProducts.data['sale_type'] ?? '',
          'coupon_code': '',
          'coupon_discount': '',
          'tx_id': purchaseDetails.purchaseID ?? '',
          'username': userData.username ?? '',
        });
        break;
      case ProductType.others:
        break;
      default:
        break;
    }
  }

//////////////////////////////  _handleInvalidPurchase  //////////////////////////////
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }
//////////////////////////////  listenToPurchaseUpdated  //////////////////////////////
  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    try {
      for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
        printPurchaseDetail(purchaseDetails, 'purchaseDetailsList');
        MyProducts? productDetail = myPacks
            .map((e) => e.products)
            .expand((element) => element)
            .firstWhereOrNull(
                (element) => element.storeId == purchaseDetails.productID);

        ///if pending
        if (purchaseDetails.status == PurchaseStatus.pending) {
          printPurchaseDetail(purchaseDetails, 'pending');
          showPendingUI();
        }

        ///handle others
        else {
          ///if error or canceled
          if (purchaseDetails.status == PurchaseStatus.error ||
              purchaseDetails.status == PurchaseStatus.canceled) {
            logger.e('purchaseDetails.status == ${purchaseDetails.status}',
                tag: tag, error: purchaseDetails.error);

            ///handle error
            handleError(purchaseDetails.error!);

            ///remove from pending purchases
            var productDetail = provider.pendingPurchases.firstWhereOrNull(
                (element) => element.id == purchaseDetails.productID);
            if (productDetail != null) {
              provider.setPurchases(purchaseDetails);
              provider.setPendingPurchase(productDetail, remove: true);
            }
          }

          ///if purchased or restored
          else if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            final bool valid = await _verifyPurchase(purchaseDetails);
            removePendingPurchase(purchaseDetails);
            if (valid) {
              printPurchaseDetail(purchaseDetails, valid);
              unawaited(deliverProduct(purchaseDetails, productDetail));
            } else {
              printPurchaseDetail(purchaseDetails, valid);
              _handleInvalidPurchase(purchaseDetails);
              return;
            }
          }
          // if (Platform.isAndroid) {
          //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
          //     final InAppPurchaseAndroidPlatformAddition androidAddition =
          //         _inAppPurchase.getPlatformAddition<
          //             InAppPurchaseAndroidPlatformAddition>();
          //     var wrapper =
          //         await androidAddition.consumePurchase(purchaseDetails);
          //     logger.i('consumePurchase:', tag: tag, error: wrapper);
          //   }
          // }

          ///complete pendingCompletePurchase
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase
                .completePurchase(purchaseDetails)
                .then((value) {
              printPurchaseDetail(purchaseDetails, tag);
            });
          }
        }
      }
    } catch (e) {
      logger.e('listenToPurchaseUpdated: error', tag: tag, error: e);
    }
  }

//////////////////////////////  printPurchaseDetail  //////////////////////////////
  printPurchaseDetail(PurchaseDetails purchaseDetails, dynamic data) {
    logger.w('printPurchaseDetail \n${data ?? ''}', tag: tag, error: {
      'purchaseID': purchaseDetails.purchaseID,
      'productID': purchaseDetails.productID,
      'status': purchaseDetails.status,
      'source': purchaseDetails.verificationData.source,
      'transactionDate': purchaseDetails.transactionDate,
    });
  }
}

///PurchasePrecessSheet
class _PurchasePrecessSheet extends StatelessWidget {
  _PurchasePrecessSheet({Key? key, required this.myPacks}) : super(key: key);
  final List<Pack> myPacks;

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(builder: (context, provider, _) {
      print('_purchases: ${provider.purchases}');
      return Container(
        color: bColor(1),
        child: ListView(
          children: [
            ///apbar
            Container(
              height: kToolbarHeight + 40,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => _handleBack(
                              context,
                              provider.purchases,
                              provider.pendingPurchases,
                              provider),
                          icon:
                              //  provider.cancelingPendingPurchase
                              //     ? const CupertinoActivityIndicator(
                              //         color: Colors.white)
                              //     :
                              const Icon(Icons.close, color: Colors.white)),
                      const Spacer(),
                      titleLargeText('Purchases Items', context,
                          useGradient: true),
                      const Spacer(),
                    ],
                  ),
                  height10(),
                ],
              ),
            ),

            ///pending purchases
            Column(
              children: [
                ...provider.pendingPurchases.map((e) => ListTile(
                      leading:
                          const CircularProgressIndicator(color: Colors.yellow),
                      title: bodyLargeText(e.title, context),
                      subtitle: bodyMedText(e.description, context),
                      trailing: const Icon(Icons.pending, color: Colors.amber),
                    )),
                ...provider.purchases.map((e) => Builder(builder: (context) {
                      MyProducts? productDetail = myPacks
                          .map((e) => e.products)
                          .expand((element) => element)
                          .firstWhereOrNull(
                              (element) => element.storeId == e.productID);
                      return ListTile(
                        leading: _getLeading(productDetail, e, context),
                        title: _getTitle(productDetail, e, context),
                        subtitle: _getSubtitle(productDetail, e, context),
                        // subtitle: Row(
                        //   children: [
                        //     bodyMedText(
                        //         e.status.name.toString().capitalize!, context),
                        //     width10(),
                        //     if (e.status == PurchaseStatus.purchased)
                        //       Builder(builder: (context) {
                        //         return IconButton(
                        //             onPressed: () {
                        //               sl
                        //                   .get<SubscriptionProvider>()
                        //                   .submitSubscriptionPackageIosPurchase({
                        //                 'package_id':
                        //                     productDetail!.data['package_id'] ??
                        //                         '',
                        //                 'sale_type':
                        //                     productDetail.data['sale_type'] ??
                        //                         '',
                        //                 'coupon_code': '',
                        //                 'coupon_discount': '',
                        //                 'tx_id': e.purchaseID ?? '',
                        //                 'username': sl
                        //                         .get<AuthProvider>()
                        //                         .userData
                        //                         .username ??
                        //                     '',
                        //               });
                        //             },
                        //             icon: const Icon(CupertinoIcons.share,
                        //                 color: Colors.white));
                        //       })
                        //   ],
                        // ),

                        trailing: _getTrailing(productDetail, e, context),
                      );
                    })),
              ],
            ),
          ],
        ),
      );
    });
  }

  _handleBack(
      BuildContext context,
      List<PurchaseDetails> purchases,
      List<ProductDetails> pendingPurchases,
      SubscriptionProvider provider) async {
    if (pendingPurchases.isNotEmpty) {
      bool? cancelPurchase = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Payment Pending'),
          content: const Text('We are still processing your purchase.\n'
              'To cancel your purchase, tap Cancel Purchase.\n on payment sheet when it appears.'),
          actions: [
            // CupertinoDialogAction(
            //   onPressed: () => Get.back(result: true),
            //   child: const Text('Cancel Purchase'),
            // ),
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      ///handle cancel purchase
      // if (cancelPurchase ?? false) {
      //   provider.setCancelingPendingPurchase(true);
      //   for (var element in pendingPurchases) {
      //     ///cancel purchase
      //     // ExamplePaymentQueueDelegate().shouldContinueTransaction(
      //     //     SKPaymentTransactionWrapper(
      //     //         payment: SKPaymentWrapper(productIdentifier: element.id),
      //     //         transactionState: SKPaymentTransactionStateWrapper.failed),
      //     //     SKStorefrontWrapper(countryCode: '', identifier: element.id));
      //     // final queueWrapper = SKPaymentQueueWrapper();
      //     // final transactions = await queueWrapper.transactions();
      //     // await Future.wait(
      //     //     transactions.map((t) => queueWrapper.finishTransaction(t)));

      //     ///complete purchase
      //     PurchaseDetails? purchaseDetails = AppStorePurchaseDetails(
      //         productID: element.id,
      //         verificationData: PurchaseVerificationData(
      //             localVerificationData: '',
      //             serverVerificationData: '',
      //             source: ''),
      //         transactionDate: DateTime.now.toString(),
      //         status: PurchaseStatus.canceled,
      //         skPaymentTransaction: SKPaymentTransactionWrapper(
      //             payment: SKPaymentWrapper(productIdentifier: element.id),
      //             transactionState: SKPaymentTransactionStateWrapper.failed));
      //     await InAppPurchase.instance
      //         .completePurchase(purchaseDetails)
      //         .then((value) {
      //       provider.setPurchases(purchaseDetails);
      //       provider.setPendingPurchase(element, remove: true);
      //       if (pendingPurchases.isEmpty) {
      //         provider.setCancelingPendingPurchase(false);
      //       }
      //     });
      //   }

      // Get.back();
      // }
    } else {
      Get.back();
    }
  }

  Widget? _getLeading(productDetails, PurchaseDetails e, BuildContext context) {
    return e.status == PurchaseStatus.purchased
        ? const Icon(Icons.check_circle_outline_rounded, color: Colors.green)
        : e.status == PurchaseStatus.error
            ? const Icon(Icons.error_outline_rounded, color: Colors.red)
            : e.status == PurchaseStatus.canceled
                ? const Icon(Icons.cancel_outlined, color: Colors.red)
                : e.status == PurchaseStatus.pending
                    ? const CupertinoActivityIndicator(color: Colors.yellow)
                    : null;
  }

  Widget? _getTitle(
      MyProducts? productDetail, PurchaseDetails e, BuildContext context) {
    return e.status == PurchaseStatus.purchased
        ? bodyLargeText(productDetail!.productDetails!.title, context)
        : e.status == PurchaseStatus.error
            ? bodyLargeText(productDetail!.productDetails!.title, context)
            : e.status == PurchaseStatus.canceled
                ? bodyLargeText(productDetail!.productDetails!.title, context)
                : e.status == PurchaseStatus.pending
                    ? bodyLargeText(
                        productDetail!.productDetails!.title, context)
                    : null;
  }

  Widget? _getSubtitle(
      MyProducts? productDetail, PurchaseDetails e, BuildContext context) {
    return e.status == PurchaseStatus.purchased
        ? bodyMedText(productDetail!.productDetails!.description, context)
        : e.status == PurchaseStatus.error
            ? bodyMedText(productDetail!.productDetails!.description, context)
            : e.status == PurchaseStatus.canceled
                ? bodyMedText(
                    productDetail!.productDetails!.description, context)
                : e.status == PurchaseStatus.pending
                    ? bodyMedText(
                        productDetail!.productDetails!.description, context)
                    : null;
  }

  ///create _get tailing to show cupertino diloag with payment details,incloding product data, purchasedata,transaction data and copy, share options
  Widget? _getTrailing(
      MyProducts? productDetail, PurchaseDetails e, BuildContext context) {
    return IconButton(
        onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => _PurchaseDetails(
                productDetail: productDetail!, purchaseDetails: e)),
        icon: const Icon(Icons.info_outline_rounded, color: Colors.white));
  }
  // Widget? _getTrailing(
  //     MyProducts? productDetail, PurchaseDetails e, BuildContext context) {
  //   return e.status == PurchaseStatus.purchased
  //       ? IconButton(
  //           onPressed: () => copyToClipboard(
  //               e.purchaseID.toString(), 'Transaction ID copied'),
  //           icon: const Icon(Icons.copy, color: Colors.white))
  //       : e.status == PurchaseStatus.error
  //           ? IconButton(
  //               onPressed: () => copyToClipboard(
  //                   e.purchaseID.toString(), 'Transaction ID copied'),
  //               icon: const Icon(Icons.copy, color: Colors.white))
  //           : e.status == PurchaseStatus.canceled
  //               ? IconButton(
  //                   onPressed: () => copyToClipboard(
  //                       e.purchaseID.toString(), 'Transaction ID copied'),
  //                   icon: const Icon(Icons.copy, color: Colors.white))
  //               : e.status == PurchaseStatus.pending
  //                   ? IconButton(
  //                       onPressed: () => copyToClipboard(
  //                           e.purchaseID.toString(), 'Transaction ID copied'),
  //                       icon: const Icon(Icons.copy, color: Colors.white))
  //                   : null;
  // }
}

class _PurchaseDetails extends StatelessWidget {
  const _PurchaseDetails(
      {super.key, required this.productDetail, required this.purchaseDetails});
  final MyProducts productDetail;
  final PurchaseDetails purchaseDetails;
  final Color normalColor = Colors.black87;
  final Color errorColor = Colors.red;
  final Color successColor = Colors.green;
  final Color pendingColor = Colors.yellow;
  final Color boldColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    PurchaseStatus status = purchaseDetails.status;
    Color statusColor = status == PurchaseStatus.purchased
        ? successColor
        : status == PurchaseStatus.error
            ? errorColor
            : status == PurchaseStatus.canceled
                ? errorColor
                : status == PurchaseStatus.pending
                    ? pendingColor
                    : normalColor;
    return CupertinoAlertDialog(
      title: titleLargeText('Transaction Details', context, color: boldColor),
      content: Column(
        children: [
          height10(),
          _getRow('Product:', productDetail.productDetails!.title, boldColor),
          height10(),
          _getRow(
              'Status:', purchaseDetails.status.name.capitalize!, statusColor),
          height10(),
          _getRow('Transaction ID:', purchaseDetails.purchaseID ?? 'N/A',
              normalColor),
          if (purchaseDetails.transactionDate != null) ...[
            height10(),
            _getRow(
                'Transaction Date:',
                formatDate(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.tryParse(purchaseDetails.transactionDate!) ?? 0),
                    'dd MMM yyyy hh:mm:ss a'),
                normalColor),

            ///source
            height10(),
            _getRow(
                'Source:',
                purchaseDetails.verificationData.source
                    .toString()
                    .split('_')
                    .join(' ')
                    .capitalize!,
                normalColor),
          ],
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Get.back(),
          child: const Text('Done'),
        ),
        if (status == PurchaseStatus.purchased) ...[
          CupertinoDialogAction(
            onPressed: () => copyToClipboard(
                purchaseDetails.purchaseID.toString(), 'Transaction ID copied'),
            child: const Text('Copy'),
          ),
          CupertinoDialogAction(
            onPressed: () => shareText(
                purchaseDetails.purchaseID.toString(), 'Transaction ID copied'),
            child: const Text('Share'),
          ),
        ],
      ],
    );
  }

  _getRow(String title, String value, Color color, [Widget? trailing]) {
    return Row(
      children: [
        Expanded(
            child: bodyMedText(title, Get.context!,
                color: normalColor, textAlign: TextAlign.start)),
        Expanded(
            child: bodyMedText(value, Get.context!,
                color: color, textAlign: TextAlign.end)),
        if (trailing != null) trailing
      ],
    );
  }

  shareText(String string, String s) {
    Share.share(string, subject: s).then((value) => Get.back());
  }
}

/// my products
class Pack {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? price;
  List<MyProducts> products = [];
  Pack({
    this.id,
    this.title,
    this.description,
    this.image,
    this.price,
    required this.products,
  });
}

class MyProducts {
  late ProductType productType;
  late PurchaseType purchaseType;
  late String id;
  late String storeId;
  String? title;
  String? description;
  final String? image;
  final String? price;
  ProductDetails? productDetails;
  Map<String, dynamic> data;
  MyProducts({
    required this.purchaseType,
    required this.productType,
    required this.id,
    required this.storeId,
    this.title,
    this.description,
    this.image,
    this.price,
    this.productDetails,
    required this.data,
  });
}

enum PurchaseType { consumable, nonConsumable, subscription }

enum ProductType { joining, dJoining, voucher, coupon, subscription, others }

class SelectPaymentMethodDialog extends StatelessWidget {
  const SelectPaymentMethodDialog(
      {super.key, this.onTap, required this.packages, this.selected});
  final Function(MapEntry)? onTap;
  final Map<String, dynamic> packages;
  final MapEntry<String, dynamic>? selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      elevation: 10,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          // color: Color(0xff0d193e),
          color: bColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 16, right: 16),
              itemCount: packages.entries.toList().length,
              itemBuilder: (BuildContext context, int index) {
                var type = packages.entries.toList()[index];
                bool selected = false;
                if (this.selected != null) {
                  selected = this.selected!.key == type.key;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)),
                    onTap: onTap != null ? () => onTap!(type) : null,
                    title: bodyLargeText(type.value, context),
                    trailing: selected
                        ? const Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
