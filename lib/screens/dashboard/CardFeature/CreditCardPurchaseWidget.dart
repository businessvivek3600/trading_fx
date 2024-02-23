import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/screens/dashboard/CardFeature/Main_Page_Card_History.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class CreditCardPurchaseScreen extends StatefulWidget {
  CreditCardPurchaseScreen({required this.card});
  final Map<String, dynamic> card;

  @override
  _CreditCardPurchaseScreenState createState() =>
      _CreditCardPurchaseScreenState();
}

class _CreditCardPurchaseScreenState extends State<CreditCardPurchaseScreen>
    with SingleTickerProviderStateMixin {
  var _formKey = GlobalKey<FormState>();
  TextEditingController fNameCtr = TextEditingController();
  TextEditingController lNameCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _toolsAnimation;

  String? selectedType;
  String? selectedPackage;
  int quantity = 1;
  String? paymentMode;
  String? cryptoType;
  decrement() => setState(() => quantity--);
  increment() => setState(() => quantity++);

  String nameOnCard = '';
  //dashboard provider
  var provider = sl.get<DashBoardProvider>();

  @override
  void initState() {
    super.initState();

    provider.getDashCardDetails(widget.card['name']).then((value) {
      setState(() {
        nameOnCard = widget.card['c_name'] ?? '';
      });
    });
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _cardAnimation = Tween<double>(begin: -500, end: 0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    _formAnimation = Tween<double>(begin: Get.height, end: 0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _toolsAnimation = Tween<double>(begin: Get.width, end: 0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    provider.loadingCardDetail = false;
    provider.purchasedCardsList.clear();
    provider.cardDetail = null;
    provider.selectedDelivery = null;
    provider.selectedPayType = null;
    super.dispose();
  }

  String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double offset = 2;
    bool annualMemberShip =
        sl.get<AuthProvider>().userData.anualMembership == 1;
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: Consumer<DashBoardProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: mainColor,
            appBar: AppBar(
              title: titleLargeText('Buy ${widget.card['name']}', context,
                  useGradient: true),
              actions: [
                Row(
                  children: [
                    SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        onPressed: provider.loadingCardDetail
                            ? null
                            : () {
                                Get.to(MainPageCardHistory(
                                    cards: provider.purchasedCardsList));
                              },
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: appLogoColor,
                          padding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: appLogoColor)),
                        ),
                        child: bodyLargeText('History', context,
                            fontWeight: FontWeight.normal, useGradient: false),
                      ),
                    ),
                    width10(),
                  ],
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildImageWidget(size, offset),
                        SizedBox(height: 20.0),
                        !annualMemberShip &&
                                widget.card['name'].toString().toLowerCase() ==
                                    'Platinum Card'.toLowerCase()
                            ? buildPlatinumUpgradeCard(context)
                            : Column(
                                children: [
                                  buildTotalSection(provider, annualMemberShip),
                                  SizedBox(height: 20.0),
                                  buildForm(provider),
                                ],
                              ),
                      ],
                    ),
                  ),
                  if (provider.loadingCardDetail)
                    Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                            color: Colors.black26,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: appLogoColor))))
                ],
              ),
            ),
            bottomNavigationBar: !annualMemberShip &&
                    widget.card['name'].toString().toLowerCase() ==
                        'Platinum Card'.toLowerCase()
                ? null
                : Padding(
                    padding: const EdgeInsets.only(
                        bottom: 25.0, left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  bool validate =
                                      _formKey.currentState?.validate() ??
                                          false;

                                  if (validate) {
                                    var data = {
                                      'card_type': widget.card['name'],
                                      'payment_type':
                                          provider.selectedPayType ?? '',
                                      'first_name': fNameCtr.text,
                                      'last_name': lNameCtr.text,
                                      'mobile_number': phoneCtr.text,
                                      'delivery_type':
                                          provider.selectedDelivery ?? '',
                                      'quantity': '${quantity}'
                                    };
                                    print(data);
                                    provider.purchaseACard(data).then((value) {
                                      if (value) {
                                        provider.selectedDelivery = null;
                                        provider.selectedPayType = null;
                                        fNameCtr.clear();
                                        lNameCtr.clear();
                                        phoneCtr.clear();
                                        quantity = 1;
                                      }
                                    });
                                  }
                                });

                                // Get.dialog(const SubscriptionPurchaseDialog());
                              },
                              child: Text('Purchase Credit Card')),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Container buildPlatinumUpgradeCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: mainColor,
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleLargeText(
              'Please upgrade to Annual Membership to order your free Platinum Card !',
              context,
              textAlign: TextAlign.center,
              fontSize: 25),
          height20(),
          titleLargeText('Platinum Club Benefits', context,
              color: appLogoColor),
          height10(),
          ...[
            _buildListItem('Free personalise Platinum Card'),
            _buildListItem('Pay for 11, Get 12 Month subscription'),
            _buildListItem(
                'Get 20% discount on merchandise and Visa Card ordering'),
            _buildListItem('Get 20% discount on MyCarClub event tickets'),
            _buildListItem('VIP seating in all MyCarClub events'),
            _buildListItem('Get 20% discount on withdrawals charges'),
          ],
          height20(),
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(25),
              color: appLogoColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                splashColor: Colors.white.withOpacity(0.5),
                onTap: () {
                  Get.to(SubscriptionPage(initPurchaseDialog: true));
                },
                child: Center(
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          height20(),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) => ListTile(
      leading: Icon(Icons.circle, color: appLogoColor, size: 15),
      title: capText(text, context, fontSize: 16, color: Colors.white70));

  AnimatedBuilder buildTotalSection(
      DashBoardProvider provider, bool annualMemberShip) {
    double cardPrice = provider.cardDetail != null
        ? (provider.cardDetail!.price ?? 0).toDouble()
        : 0;
    double postage = 0.0;
    double discountPer = 0.0;
    bool free = false;
    if (provider.selectedDelivery != null) {
      if (provider.cardDetail != null) {
        free = provider.cardDetail!.free;
        discountPer =
            !annualMemberShip ? 0.0 : provider.cardDetail!.discountPer ?? 0.0;
        if (provider.cardDetail!.delivery != null &&
            provider.cardDetail!.delivery!.isNotEmpty) {
          postage = provider.cardDetail!.delivery!
                  .firstWhere(
                      (element) => element.name == provider.selectedDelivery!)
                  .price
                  ?.toDouble() ??
              0.0;
        }
      }
    }
    double subTotal = (cardPrice + postage);
    double total =
        (subTotal * quantity * ((100 - discountPer) / 100) * (free ? 0 : 1));
    // free = true;
    return AnimatedBuilder(
        animation: _toolsAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(_toolsAnimation.value, 0),
            child: Container(
              width: double.maxFinite,
              // height: 120,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  // capText('', context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Card price: ', context,
                          color: Colors.white70),
                      bodyLargeText(
                          '${currency_icon}${cardPrice.toStringAsFixed(1)}',
                          context,
                          color: Colors.white70),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('Postage: ', context,
                          color: Colors.white70),
                      bodyLargeText(
                          '${currency_icon}${postage.toStringAsFixed(1)}',
                          context,
                          color: Colors.white70),
                    ],
                  ),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('SubTotal: ', context, fontSize: 18),
                      bodyLargeText(
                          '${currency_icon}${subTotal.toStringAsFixed(1)}',
                          context,
                          color: appLogoColor,
                          fontSize: 18),
                    ],
                  ),
                  height5(),
                  height5(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          bodyLargeText('Net Payable: ', context, fontSize: 18),
                          if (discountPer > 0)
                            bodyLargeText(
                                '(${discountPer.toStringAsFixed(0)}% OFF)',
                                context,
                                color: Colors.green),
                        ],
                      ),
                      bodyLargeText(
                          '${currency_icon}${total.toStringAsFixed(1)}',
                          context,
                          color: appLogoColor,
                          fontSize: 18),
                    ],
                  ),
                  height5(),
                  if (free)
                    Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          // color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                          child: bodyLargeText(
                              'Your first ${widget.card['name'] ?? ""} is free for you',
                              context,
                              color: Colors.green.shade600)),
                    ),
                  // height5(),
                ],
              ),
            ),
          );
        });
  }

  AnimatedBuilder buildForm(DashBoardProvider provider) {
    bool free = false;
    if (provider.selectedDelivery != null) {
      if (provider.cardDetail != null) {
        free = provider.cardDetail!.free;
      }
    }
    print((free));
    return AnimatedBuilder(
        animation: _cardAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, _formAnimation.value),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      bodyLargeText('No of Cards', context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                      width10(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: quantity > 1
                                ? free
                                    ? null
                                    : decrement
                                : null,
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: quantity > 1 && !free
                                        ? Colors.white
                                        : Colors.grey[700],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: quantity > 1 ? 5 : 0,
                                          spreadRadius: quantity > 1 ? 1 : 0)
                                    ]),
                                child: Center(
                                    child: Icon(Icons.remove,
                                        color: quantity <= 1
                                            ? Colors.white
                                            : Colors.black))),
                          ),
                          width10(),
                          bodyLargeText('$quantity', context,
                              color: Colors.white, fontSize: 22),
                          width10(),
                          GestureDetector(
                            onTap: quantity >= 10
                                ? null
                                : free
                                    ? null
                                    : increment,
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: quantity < 10 && !free
                                        ? Colors.white
                                        : Colors.grey[700],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          spreadRadius: 1)
                                    ]),
                                child: Center(
                                    child: Icon(Icons.add,
                                        color: quantity >= 10 || free
                                            ? Colors.white
                                            : Colors.black))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  height10(),
                  TextFormField(
                    cursorColor: Colors.white,
                    controller: fNameCtr,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (val) {
                      if (val == null) {
                        return 'Please enter your first name.';
                      }
                      if (val.isEmpty) {
                        return 'Please enter your first name correctly.';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      calculateName(widget.card['c_name']);
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    cursorColor: Colors.white,
                    controller: lNameCtr,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (val) {
                      if (val == null) {
                        return 'Please enter your last name.';
                      }
                      if (val.isEmpty) {
                        return 'Please enter your last name correctly.';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      print(nameOnCard);
                      calculateName(widget.card['c_name']);
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.phone,
                    controller: phoneCtr,
                    style: TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    validator: (val) {
                      if (val == null) {
                        return 'Please enter your phone number.';
                      }
                      if (val.isEmpty) {
                        return 'Please enter your phone number correctly.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Delivery Type',
                        filled: true,
                        hintText: 'Select'),
                    isDense: true,
                    alignment: AlignmentDirectional.bottomCenter,
                    value: provider.selectedDelivery,
                    items: [
                      // DropdownMenuItem<String>(
                      //   value: null,
                      //   child: titleLargeText('Wallet', context,
                      //       color: Colors.white54),
                      //   enabled: false,
                      // ),
                      if (!provider.loadingCardDetail &&
                          provider.cardDetail != null &&
                          (provider.cardDetail!.delivery != null ||
                              provider.cardDetail!.delivery!.isNotEmpty))
                        ...provider.cardDetail!.delivery!.map(
                          (e) => DropdownMenuItem<String>(
                            value: e.name,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: bodyMedText(e.name ?? "", context),
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      provider.setDeliveryType(value);
                    },
                    borderRadius: BorderRadius.circular(15),
                    iconEnabledColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    menuMaxHeight: double.maxFinite,
                    dropdownColor: bColor(),
                    validator: (val) {
                      if (val == null) {
                        return 'Please select delivery type.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Payment Type',
                        filled: true,
                        hintText: 'Select'),
                    isDense: true,
                    value: provider.selectedPayType,
                    alignment: AlignmentDirectional.bottomCenter,
                    items: [
                      if (!provider.loadingCardDetail &&
                          provider.cardDetail != null &&
                          (provider.cardDetail!.paymentType != null ||
                              provider
                                  .cardDetail!.paymentType!.entries.isNotEmpty))
                        ...provider.cardDetail!.paymentType!.entries.map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: bodyMedText(e.value ?? "", context),
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      provider.setPayType(value);
                    },
                    borderRadius: BorderRadius.circular(15),
                    iconEnabledColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    menuMaxHeight: double.maxFinite,
                    dropdownColor: bColor(),
                    validator: (val) {
                      if (val == null) {
                        return 'Please select payment type.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        });
  }

  AnimatedBuilder buildImageWidget(Size size, double offset) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_cardAnimation.value, 0),
          child: Container(
            width: size.width * 0.8,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: buildCachedNetworkImage(widget.card['image'],
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
                    right: widget.card['name'] == 'Visa Card' ? null : 20,
                    left: widget.card['name'] == 'Visa Card' ? 30 : null,
                    bottom: widget.card['name'] == 'Visa Card' ? 5 : null,
                    top: widget.card['name'] == 'Visa Card' ? null : 75,
                    child: titleLargeText(nameOnCard, context,
                        textAlign: TextAlign.start)),
                if (widget.card['qr_code'] != null)
                  Positioned(
                      left: 30,
                      bottom: 75,
                      child: SizedBox(
                          height: 60,
                          width: 60,
                          child:
                              buildCachedNetworkImage(widget.card['qr_code'])))
              ],
            ),
          ),
        );
      },
    );
  }

  String calculateName(String? cName) {
    if (cName != null) {
      nameOnCard = cName;
    }
    if (fNameCtr.text.isNotEmpty && lNameCtr.text.isEmpty) {
      nameOnCard = fNameCtr.text;
    } else if (fNameCtr.text.isNotEmpty && lNameCtr.text.isNotEmpty) {
      nameOnCard = (fNameCtr.text + ' ' + lNameCtr.text).capitalize!;
    } else if (fNameCtr.text.isEmpty && lNameCtr.text.isNotEmpty) {
      nameOnCard = lNameCtr.text;
    }
    setState(() {});
    return nameOnCard;
  }
}
