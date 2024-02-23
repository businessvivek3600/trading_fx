import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/subscription_package_model.dart';
import '/providers/card_payment_provider.dart';
import '/providers/subscription_provider.dart';
import '/screens/card_form/PaymentCardScreen.dart';
import '/screens/card_form/payment_card.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import 'package:provider/provider.dart';

import 'input_formatters.dart';
import 'my_strings.dart';

class CardFormWidget extends StatefulWidget {
  CardFormWidget(
      {Key? key,
      this.subscriptionPackage,
      required this.orderId,
      this.amount,
      this.currency})
      : super(key: key);
  final SubscriptionPackage? subscriptionPackage;
  final String orderId;
  final String? currency;
  final double? amount;

  @override
  _CardFormWidgetState createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends State<CardFormWidget> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidateMode = AutovalidateMode.disabled;

  var _card = PaymentCard();

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    var provider = sl.get<CardPaymentProvider>();
    provider.orderStatus = 0;
    provider.customer.clear();
    provider.paymentMethod.clear();
    provider.attachPm.clear();
    provider.updatedCustomer.clear();
    provider.subscriptionDetails.clear();
    provider.invoice.clear();
    provider.paymentIntent.clear();
    provider.confirmedPaymentIntent.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        primaryFocus?.unfocus();
        bool willpop = false;
        var provider = sl.get<CardPaymentProvider>();
        var orderStatus = provider.orderStatus;
        print(
            'order status $orderStatus ${(orderStatus != 0 && orderStatus != 1 && orderStatus != 2)}');
        if (orderStatus == 1 || orderStatus == 2) {
          willpop = true;
          Get.back();
        } else {
          await AwesomeDialog(
            dialogType: DialogType.question,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            animType: AnimType.bottomSlide,
            title: 'Do you really want to cancel?',
            context: context,
            btnCancelText: 'No',
            btnOkText: 'Yes Sure!',
            btnCancelOnPress: () {
              willpop = false;
            },
            btnOkOnPress: () async {
              sl.get<CardPaymentProvider>().orderStatus = 3;
              print('order status <2> $orderStatus');
              willpop = await sl
                  .get<CardPaymentProvider>()
                  .submitCardPayment(widget.orderId, amount: widget.amount);
            },
            reverseBtnOrder: true,
          ).show();
        }
        print(
            '0 $willpop  ${sl.get<CardPaymentProvider>().orderStatus} *******************');
        return willpop;
      },
      child: Consumer<CardPaymentProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: mainColor,
            appBar: AppBar(
              title: Text('Card Payment'),
              shadowColor: Colors.white,
              leading: IconButton(
                  onPressed: () {
                    // if (widget.subscriptionPackage != null) {
                    print(
                        'order status  ${provider.orderStatus} ${(provider.orderStatus != 1 && provider.orderStatus != 2)}');
                    if (provider.orderStatus == 1 ||
                        provider.orderStatus == 2) {
                      Get.back();
                    } else {
                      AwesomeDialog(
                        dialogType: DialogType.question,
                        dismissOnBackKeyPress: false,
                        dismissOnTouchOutside: false,
                        animType: AnimType.bottomSlide,
                        title: 'Do you really want to cancel?',
                        context: context,
                        btnCancelText: 'No',
                        btnOkText: 'Yes Sure!',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          provider.orderStatus = 3;
                          print('order status <2> ${provider.orderStatus}');
                          provider
                              .submitCardPayment(widget.orderId,
                                  amount: widget.amount)
                              .then((value) {});
                        },
                        reverseBtnOrder: true,
                      ).show();
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  )),
            ),
            body: GestureDetector(
              onTap: () => primaryFocus?.unfocus(),
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: userAppBgImageProvider(context),
                        fit: BoxFit.cover,
                        opacity: 1)),
                child: CardSectionWidget(onSave: handleCallback),
              ),
            ),
            // bottomNavigationBar: _getPayButton(provider),
          );
        },
      ),
    );
  }

  void handleCallback({
    required String cardHolderName,
    required String cardNumber,
    required String cvvCode,
    required String expMonth,
    required String expYear,
  }) {
    var provider = sl.get<CardPaymentProvider>();
    print('Card Holder Name: $cardHolderName');
    print('Card Number: $cardNumber');
    print('CVV Code: $cvvCode');
    print('Expiration Month: $expMonth');
    print('Expiration Year: $expYear');

    widget.subscriptionPackage != null
        ? provider.paySubscription(
            name: cardHolderName,
            number: cardNumber,
            expMonth: expMonth,
            expYear: expYear,
            cvc: cvvCode,
            priceId: widget.subscriptionPackage!.priceId!,
            joiningId: sl.get<SubscriptionProvider>().customerRenewal == 1
                ? sl.get<SubscriptionProvider>().joiningPriceId
                : null,
            orderId: widget.orderId,
          )
        : widget.amount != null
            ? provider.payPayment(
                name: cardHolderName,
                number: cardNumber,
                expMonth: expMonth,
                expYear: expMonth,
                cvc: cvvCode,
                currency: widget.currency!,
                amount: widget.amount!,
                orderId: widget.orderId,
              )
            : () {};
  }

  Widget _getPayButton(CardPaymentProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _validateInputs(provider),
                  // color: CupertinoColors.activeBlue,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    child: const Text(Strings.pay,
                        style: const TextStyle(fontSize: 17.0)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildDetails(BuildContext context, SubscriptionPackage package) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.transparent, width: 2)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // height: 70,
            width: Get.width / 2,
            child: CachedNetworkImage(
                imageUrl: package.image ?? '',
                placeholder: (context, url) => SizedBox(
                      height: 50,
                      width: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: appLogoColor.withOpacity(0.5)),
                      ),
                    ),
                errorWidget: (context, url, error) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 100,
                            width: 70,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(10)),
                            child: assetImages(Assets.appWebLogo)),
                      ],
                    ),
                cacheManager: CacheManager(Config(
                    "${AppConstants.packageID}_${package.name}",
                    stalePeriod: const Duration(days: 7)))),
          ),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateMode,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white24,
            boxShadow: [BoxShadow(color: Colors.black)],
            image: DecorationImage(
              image: assetImageProvider(Assets.appWebLogoWhite),
              // image: CardUtils.getCardImageProvider(_paymentCard.type)!,
              opacity: 0.2,
              fit: BoxFit.contain,
              colorFilter:
                  ColorFilter.mode(Colors.black12, BlendMode.colorDodge),
            ),
            border: Border.all(color: Colors.white54, width: 2)),
        child: Column(
          children: <Widget>[
            height20(),
            TextFormField(
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  size: 20.0,
                  color: Colors.white,
                ),
                hintText: 'Card Holder Name',
                labelText: 'Card Holder Name',
              ),
              onSaved: (String? value) {
                _card.name = value;
                _paymentCard.name = value;
              },
              keyboardType: TextInputType.text,
              validator: (String? value) =>
                  value!.isEmpty ? Strings.fieldReq : null,
              onEditingComplete: () => primaryFocus?.nextFocus(),
            ),
            height10(15),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                CardNumberInputFormatter()
              ],
              controller: numberController,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white54)),
                filled: true,
                prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CardUtils.getCardIcon(_paymentCard.type)!]),
                hintText: '#### #### #### #### ###',
                labelText: 'Card Number',
              ),
              onSaved: (String? value) {
                print('onSaved = $value');
                print('Num controller has = ${numberController.text}');
                _paymentCard.number = CardUtils.getCleanedNumber(value!);
              },
              validator: CardUtils.validateCardNum,
              onEditingComplete: () => primaryFocus?.nextFocus(),
            ),
            height10(15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      filled: true,
                      prefixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/card_images/card_cvv.png',
                              width: 20.0,
                              fit: BoxFit.contain,
                              color: Colors.white),
                        ],
                      ),
                      hintText: 'Number behind the card',
                      labelText: 'CVV',
                    ),
                    validator: CardUtils.validateCVV,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _paymentCard.cvv = int.parse(value!),
                    onEditingComplete: () => primaryFocus?.nextFocus(),
                  ),
                ),
                width10(),
                Expanded(
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      CardMonthInputFormatter()
                    ],
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white54)),
                      filled: true,
                      prefixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/card_images/calender.png',
                              width: 20.0, color: Colors.white),
                        ],
                      ),
                      hintText: 'MM/YY',
                      labelText: 'Expiry Date',
                    ),
                    validator: CardUtils.validateDate,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      List<int> expiryDate = CardUtils.getExpiryDate(value!);
                      _paymentCard.month = expiryDate[0];
                      _paymentCard.year = expiryDate[1];
                    },
                    onEditingComplete: () => primaryFocus?.unfocus(),
                  ),
                ),
              ],
            ),
            height10(20),
            // Container(
            //   alignment: Alignment.center,
            //   child: _getPayButton(),
            // )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs(CardPaymentProvider provider) {
    final FormState form = _formKey.currentState!;
    primaryFocus?.unfocus();
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      _showInSnackBar('Please fill valid card details before submitting.');
    } else {
      form.save();
      widget.subscriptionPackage != null
          ? provider.paySubscription(
              name: _paymentCard.name ?? 'N/A',
              number: _paymentCard.number!,
              expMonth: (_paymentCard.month!).toString(),
              expYear: (_paymentCard.year ?? '').toString(),
              cvc: (_paymentCard.cvv!).toString(),
              priceId: widget.subscriptionPackage!.priceId!,
              joiningId: sl.get<SubscriptionProvider>().customerRenewal == 1
                  ? sl.get<SubscriptionProvider>().joiningPriceId
                  : null,
              orderId: widget.orderId,
            )
          : widget.amount != null
              ? provider.payPayment(
                  name: _paymentCard.name ?? 'N/A',
                  number: _paymentCard.number!,
                  expMonth: (_paymentCard.month!).toString(),
                  expYear: (_paymentCard.year ?? '').toString(),
                  cvc: (_paymentCard.cvv!).toString(),
                  currency: widget.currency!,
                  amount: widget.amount!,
                  orderId: widget.orderId,
                )
              : () {};
    }
  }

  void _showInSnackBar(String value) => Fluttertoast.showToast(msg: value);
}
