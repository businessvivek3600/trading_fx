import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/providers/auth_provider.dart';
import '/providers/subscription_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class SubscriptionPurchaseDialog extends StatefulWidget {
  const SubscriptionPurchaseDialog({
    super.key,
  });

  @override
  State<SubscriptionPurchaseDialog> createState() =>
      _SubscriptionPurchaseDialogState();
}

class _SubscriptionPurchaseDialogState extends State<SubscriptionPurchaseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  TextEditingController typeController = TextEditingController();
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    var provider = sl.get<SubscriptionProvider>();
    provider.selectedPaymentTypeKey = null;
    provider.selectedPackage = null;
    provider.couponVerified = null;
    provider.voucherCodeController.clear();
    provider.typeController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              color: bColor(),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleLargeText('Pick your pack', context,
                                useGradient: true),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        height20(),
                        Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                color: appLogoColor),
                            width10(),
                            bodyLargeText(
                                'Unlimited access to all courses', context,
                                fontWeight: FontWeight.w500,
                                useGradient: false),
                          ],
                        ),
                        height10(),
                        Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                color: appLogoColor),
                            width10(),
                            Expanded(
                              child: bodyLargeText(
                                  'You can withdraw incomes to your bank account whenever you want.',
                                  context,
                                  fontWeight: FontWeight.w500,
                                  useGradient: false),
                            ),
                          ],
                        ),
                        height10(),
                        Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                color: appLogoColor),
                            width10(),
                            bodyLargeText(
                                'Unlimited access to all audios', context,
                                fontWeight: FontWeight.w500,
                                useGradient: false),
                          ],
                        ),
                        height20(),
                        bodyLargeText('Payment Type', context,
                            fontWeight: FontWeight.w500,
                            useGradient: false,
                            fontSize: 16),
                        height10(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: provider.typeController,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    barrierColor:
                                        const Color.fromARGB(36, 202, 202, 202),
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        SelectPaymentMethodDialog(
                                            packages: provider.paymentTypes,
                                            selected: provider
                                                        .selectedPaymentTypeKey !=
                                                    null
                                                ? MapEntry(
                                                    provider
                                                        .selectedPaymentTypeKey!,
                                                    provider.paymentTypes[provider
                                                        .selectedPaymentTypeKey!])
                                                : null,
                                            onTap: (value) {
                                              Get.back();
                                              if (provider
                                                      .selectedPaymentTypeKey !=
                                                  value.key) {
                                                provider.voucherCodeController
                                                    .clear();
                                              }
                                              provider.setSelectedTypeKey(
                                                  value.key);
                                              provider.typeController.text =
                                                  value.value;
                                            }),
                                    // buildDraggableScrollableSheet(provider),
                                  );
                                },
                                enabled: true,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: 'Select method',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    helperText: provider
                                                .selectedPaymentTypeKey ==
                                            'MCC Commission Wallet'
                                        ? '${provider.typeController.text}: $currency_icon${provider.commissionMBal.toStringAsFixed(2)}'
                                        : provider.selectedPaymentTypeKey ==
                                                'NG Commission Wallet'
                                            ? '${provider.typeController.text}: $currency_icon${provider.commissionNBal.toStringAsFixed(2)}'
                                            : provider.selectedPaymentTypeKey ==
                                                    'Amgen Wallet'
                                                ? '${provider.typeController.text}: $currency_icon${provider.amgenBal.toStringAsFixed(2)}'
                                                : provider.selectedPaymentTypeKey ==
                                                        'NG Cash Wallet'
                                                    ? '${provider.typeController.text}: $currency_icon${provider.cashNBal.toStringAsFixed(2)}'
                                                    : null,
                                    helperStyle: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    suffixIcon: const Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                          if (provider.couponVerified != null &&
                              provider.couponVerified!)
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
                  if (provider.discount_note != null)
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

                  //packs
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, bottom: kToolbarHeight),
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        ...provider.packages.map((package) {
                          bool selected = provider.selectedPackage == package;
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  provider.selectedPackage = package;
                                  setState(() {});
                                  AwesomeDialog(
                                    dialogType: DialogType.info,
                                    dismissOnBackKeyPress: false,
                                    dismissOnTouchOutside: false,
                                    animType: AnimType.bottomSlide,
                                    title: 'Do you want to add subscription?',
                                    context: context,
                                    btnCancelText: 'No',
                                    btnOkText: 'Yes Sure!',
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      print(provider.selectedPaymentTypeKey);
                                      primaryFocus?.unfocus();
                                      provider.buySubscription(package);
                                    },
                                    reverseBtnOrder: true,
                                  ).show();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: (selected
                                                  ? appLogoColor
                                                  : Colors.white)
                                              .withOpacity(0.7),
                                          width: selected ? 2 : 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: buildCachedNetworkImage(
                                            package.image ?? '')),
                                  ),
                                  // child: Image.network(package.image ?? ''),
                                ),
                              ),

                              // if (selected)
                              if (selected)
                                Positioned(
                                    right: 15,
                                    top: 15,
                                    child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: appLogoColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 15)))
                            ],
                          );
                        }),
                      ],
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

  AnimatedContainer buildCouponFieldSuffix(SubscriptionProvider provider) {
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
                              strokeWidth: 2, color: Colors.white)))
                ],
              )
            : Text(
                provider.couponVerified == null ||
                        provider.couponVerified == false
                    ? (provider.selectedPaymentTypeKey == 'E-Pin'
                        ? 'Apply'
                        : 'Check')
                    : 'Clear',
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  _handleCoupuon(SubscriptionProvider provider) {
    FocusScope.of(context).unfocus();
    bool couponAdded =
        provider.couponVerified != null && provider.couponVerified!;
    if (couponAdded) {
      provider.voucherCodeController.clear();
      provider.couponVerified = null;
    } else {
      if (provider.voucherCodeController.text.isNotEmpty) {
        if (provider.packages.isNotEmpty) {
          provider.verifyCoupon(provider.voucherCodeController.text);
        } else {
          Fluttertoast.showToast(msg: 'Please select a subscription pack');
        }
      } else {
        Fluttertoast.showToast(msg: 'Please enter coupon code');
      }
    }
    setState(() {});
  }
}

// DraggableScrollableSheet buildDraggableScrollableSheet(
//     SubscriptionProvider provider) {
//   return DraggableScrollableSheet(
//     maxChildSize: 0.9,
//     minChildSize: 0.3,
//     initialChildSize: 0.7,
//     builder: (BuildContext context, ScrollController scrollController) {
//       return Material(
//         color: Colors.transparent,
//         child: Container(
//           margin: EdgeInsets.only(top: kToolbarHeight),
//           decoration: BoxDecoration(
//             // color: Color(0xff0d193e),
//             color: defaultBottomSheetColor,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(15),
//               topRight: Radius.circular(15),
//             ),
//           ),
//           child: Stack(
//             children: [
//               ListView.builder(
//                 padding: EdgeInsets.only(top: 30, bottom: 20),
//                 controller: scrollController,
//                 itemCount: provider.paymentTypes.entries.toList().length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var type = provider.paymentTypes.entries.toList()[index];
//                   return ListTile(
//                       onTap: () {
//                         Get.back();
//                         provider.setSelectedTypeKey(type.key);
//                         provider.typeController.text = type.value;
//                         print(provider.selectedTypeKey);
//                         if (type.key != 'E-Pin') {
//                           provider.voucherController.clear();
//                         }
//                       },
//                       title: bodyLargeText(type.value, context));
//                 },
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 3,
//                     margin: EdgeInsets.symmetric(vertical: 10),
//                     width: 30,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(5),
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

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
