import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/base/user_model.dart';
import '/database/repositories/subscription_repo.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/subscription_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import '/widgets/show_custom_dialog.dart';
import 'package:provider/provider.dart';

class CardPaymentProvider extends ChangeNotifier {
  final SubscriptionRepo subscriptionRepo;
  CardPaymentProvider({required this.subscriptionRepo});
  final client = http.Client();
  bool makingPayment = false;
  bool paymentDone = false;
  bool errorOccurred = false;
  bool creatingCustomer = false;
  bool creatingPayMethod = false;
  bool attachingPayMethod = false;
  bool updatingCustomer = false;
  bool creatingIntent = false;
  bool confirmingIntent = false;
  bool creatingSubscription = false;
  bool creatingInvoice = false;
  bool submittingCardPayment = false;

  String initialText = 'Initialising Payment...';
  String processText = 'Payment Processing...\nDo not leave the screen';
  String confirmText = 'Payment Confirmation...\nDo not leave the screen';
  String? errorText;
  String successText = 'Payment Successful';
  int orderStatus = 0;

  static Map<String, String> headers = {
    'Authorization':
        'Bearer ${AppConstants.testMode ? AppConstants.stripeTestSecretKey : AppConstants.stripeSecretKey}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  var customer = {};
  var paymentMethod = {};
  var attachPm = {};
  var updatedCustomer = {};
  var paymentIntent = {};
  var confirmedPaymentIntent = {};
  var subscriptionDetails = {};
  var invoice = {};

  //payment
  Future<void> payPayment({
    required String name,
    required String number,
    required String expMonth,
    required String expYear,
    required String cvc,
    required double amount,
    required String currency,
    required String orderId,
    String? joiningId,
  }) async {
    orderStatus = 0;
    customer.clear();
    paymentMethod.clear();
    attachPm.clear();
    updatedCustomer.clear();
    paymentIntent.clear();
    confirmedPaymentIntent.clear();
    makingPayment = true;
    paymentDone = false;
    errorOccurred = false;
    creatingCustomer = false;
    creatingPayMethod = false;
    attachingPayMethod = false;
    updatingCustomer = false;
    creatingIntent = false;
    confirmingIntent = false;
    submittingCardPayment = false;
    notifyListeners();
    showPaymentProcessDialog();
    if (isOnline) {
      try {
        creatingCustomer = true;
        notifyListeners();
        await _createCustomer(name: name).then((value) async {
          customer = value;
          print(
              '_customer ${customer}  ${customer.entries.toList().isNotEmpty && !errorOccurred}');
          if (customer.entries.toList().isNotEmpty) {
            creatingCustomer = false;
            creatingPayMethod = true;
            notifyListeners();
          } else {
            makingPayment = false;
            errorOccurred = true;
            notifyListeners();
          }
        });
        if (customer.entries.toList().isNotEmpty && !errorOccurred) {
          paymentMethod = await _createPaymentMethod(
              number: number, expMonth: expMonth, expYear: expYear, cvc: cvc);
          print('_createPaymentMethod $paymentMethod');
        } else {
          makingPayment = false;
          orderStatus = 2;
          errorOccurred = true;
          notifyListeners();
        }

        if (paymentMethod.entries.toList().isNotEmpty && !errorOccurred) {
          creatingPayMethod = false;
          attachingPayMethod = true;
          notifyListeners();
          attachPm =
              await _attachPaymentMethod(paymentMethod['id'], customer['id']);
          print('attachPm ${attachPm}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (attachPm.entries.toList().isNotEmpty && !errorOccurred) {
          attachingPayMethod = false;
          updatingCustomer = true;
          notifyListeners();
          updatedCustomer =
              await _updateCustomer(paymentMethod['id'], customer['id']);
          print('_updateCustomer ${updatedCustomer}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (updatedCustomer.entries.toList().isNotEmpty && !errorOccurred) {
          updatingCustomer = false;
          creatingIntent = true;
          notifyListeners();
          paymentIntent =
              await _createPaymentIntents(amount, currency, customer['id']);
          print('_createPaymentIntents ${paymentIntent}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (paymentIntent.entries.toList().isNotEmpty && !errorOccurred) {
          creatingIntent = false;
          confirmingIntent = true;
          notifyListeners();
          confirmedPaymentIntent = await _confirmPaymentIntents(
              paymentIntent['id'], paymentMethod['id']);
          print('_confirmPaymentIntents ${confirmedPaymentIntent}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }
        if (confirmedPaymentIntent.entries.toList().isNotEmpty &&
            !errorOccurred &&
            confirmedPaymentIntent['status'] == 'succeeded') {
          confirmingIntent = false;
          makingPayment = false;
          paymentDone = true;
          orderStatus = 1;
          notifyListeners();
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }
      } catch (e) {
        makingPayment = false;
        errorOccurred = true;
        orderStatus = 2;
        notifyListeners();
      }
    } else {
      Toasts.showWarningNormalToast('You are offline');
    }
    print('error text $errorText');
    await Future.delayed(Duration(seconds: 3), () {});
    Get.back();
    submitCardPayment(orderId, amount: amount);
  }

  Future<Map<String, dynamic>> _confirmPaymentIntents(
      String intentId, String methodId) async {
    Map<String, dynamic> data = {};

    final String url =
        'https://api.stripe.com/v1/payment_intents/$intentId/confirm';
    Map<String, dynamic> body = {'payment_method': methodId};
    try {
      var response =
          await client.post(Uri.parse(url), headers: headers, body: body);
      // print('_confirmPaymentIntents ${response.body} ${response.statusCode}');

      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future<Map<String, dynamic>> _createPaymentIntents(
      double amount, String currency, String customerId) async {
    final String url = 'https://api.stripe.com/v1/payment_intents';
    Map<String, dynamic> data = {};

    Map<String, dynamic> body = {
      'amount': ((amount * 100).floor()).toString(),
      'currency': currency,
      'customer': customerId,
      'payment_method_types[]': 'card'
    };
    try {
      var response =
          await client.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  //Subscription
  Future<void> paySubscription({
    required String name,
    required String number,
    required String expMonth,
    required String expYear,
    required String cvc,
    required String priceId,
    required String orderId,
    String? joiningId,
  }) async {
    orderStatus = 0;
    customer.clear();
    paymentMethod.clear();
    attachPm.clear();
    updatedCustomer.clear();
    subscriptionDetails.clear();
    invoice.clear();
    makingPayment = true;
    paymentDone = false;
    errorOccurred = false;
    creatingCustomer = false;
    creatingPayMethod = false;
    attachingPayMethod = false;
    updatingCustomer = false;
    creatingSubscription = false;
    creatingInvoice = false;
    submittingCardPayment = false;
    notifyListeners();
    showPaymentProcessDialog();
    print('pay payment ${joiningId}');
    if (isOnline) {
      try {
        creatingCustomer = true;
        notifyListeners();
        await _createCustomer(name: name).then((value) async {
          customer = value;
          print(
              '_customer ${customer}  ${customer.entries.toList().isNotEmpty && !errorOccurred}');
          if (customer.entries.toList().isNotEmpty) {
            creatingCustomer = false;
            creatingPayMethod = true;
            notifyListeners();
          } else {
            makingPayment = false;
            errorOccurred = true;
            notifyListeners();
          }
        });
        if (customer.entries.toList().isNotEmpty && !errorOccurred) {
          paymentMethod = await _createPaymentMethod(
              number: number, expMonth: expMonth, expYear: expYear, cvc: cvc);
          print('_createPaymentMethod $paymentMethod');
        } else {
          makingPayment = false;
          orderStatus = 2;
          errorOccurred = true;
          notifyListeners();
        }

        if (paymentMethod.entries.toList().isNotEmpty && !errorOccurred) {
          creatingPayMethod = false;
          attachingPayMethod = true;
          notifyListeners();
          attachPm =
              await _attachPaymentMethod(paymentMethod['id'], customer['id']);
          print('attachPm ${attachPm}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (attachPm.entries.toList().isNotEmpty && !errorOccurred) {
          attachingPayMethod = false;
          updatingCustomer = true;
          notifyListeners();
          updatedCustomer =
              await _updateCustomer(paymentMethod['id'], customer['id']);
          print('_updateCustomer ${updatedCustomer}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (updatedCustomer.entries.toList().isNotEmpty && !errorOccurred) {
          updatingCustomer = false;
          creatingSubscription = true;
          notifyListeners();
          subscriptionDetails = await _createSubscriptions(customer['id'],
              priceId: priceId, joiningId: joiningId);
          print('_createSubscriptions ${subscriptionDetails}');
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }

        if (subscriptionDetails.entries.toList().isNotEmpty && !errorOccurred) {
          creatingSubscription = false;
          creatingInvoice = true;
          notifyListeners();
          invoice =
              await _retrieveInvoice(subscriptionDetails['latest_invoice']);
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }
        if (invoice.entries.toList().isNotEmpty &&
            !errorOccurred &&
            invoice['paid']) {
          creatingInvoice = false;
          makingPayment = false;
          paymentDone = true;
          orderStatus = 1;
          notifyListeners();
        } else {
          makingPayment = false;
          errorOccurred = true;
          orderStatus = 2;
          notifyListeners();
        }
        /* await Future.delayed(Duration(microseconds: 0), () async {
        attachingPayMethod = false;
        updatingCustomer = true;
        notifyListeners();
      });
      await Future.delayed(Duration(seconds: 2), () async {
        updatingCustomer = false;
        creatingSubscription = true;
        notifyListeners();
      });
      await Future.delayed(Duration(seconds: 2), () async {
        creatingSubscription = false;
        makingPayment = false;
        notifyListeners();
      });
      await Future.delayed(Duration(seconds: 1), () {
        paymentDone = true;
        notifyListeners();
      });
      await Future.delayed(Duration(seconds: 1), () {});
*/
        //

        // attachPm =
        //     await _attachPaymentMethod(_paymentMethod['id'], _customer['id']);
        // print('attachPm ${attachPm}');
        // updatedCustomer =
        //     await _updateCustomer(_paymentMethod['id'], _customer['id']);
        // print('_updateCustomer ${updatedCustomer}');
        // subscriptionDetails = await _createSubscriptions(_customer['id'],
        //     priceId: priceId, joiningId: joiningId);
        // print('_createSubscriptions ${subscriptionDetails}');
      } catch (e) {
        makingPayment = false;
        errorOccurred = true;
        orderStatus = 2;
        notifyListeners();
      }
    } else {
      Toasts.showWarningNormalToast('You are offline');
    }
    print('error text $errorText');

    await Future.delayed(Duration(seconds: 3), () {});
    Get.back();
    submitCardPayment(orderId);
  }

  Future<bool> submitCardPayment(orderId, {double? amount}) async {
    bool status = false;
    submittingCardPayment = true;
    notifyListeners();
    try {
      Map<String, dynamic> data = {
        'order_id': orderId,
        'order_status': orderStatus.toString(),
        'stripe_customer_id':
            customer.entries.toList().isNotEmpty ? customer['id'] : '',
      };
      if (amount == null) {
        data.addAll({
          'stripe_invoice_id': subscriptionDetails.entries.toList().isNotEmpty
              ? subscriptionDetails['latest_invoice']
              : '',
        });
      } else {
        data.addAll({
          'stripe_payment_id':
              confirmedPaymentIntent.entries.toList().isNotEmpty
                  ? confirmedPaymentIntent['id']
                  : ''
        });
      }
      showLoading();
      ApiResponse apiResponse = await subscriptionRepo.submitCardPayment(
          amount != null
              ? AppConstants.cashWalletCardPaymentFundSubmit
              : AppConstants.submitCardInvoice,
          data);
      Get.back();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        String message = '';
        try {
          status = map["status"];
          if (map['is_logged_in'] != 1) {
            logOut('submitCardPayment');
          }
        } catch (e) {}
        try {
          message = map["message"];
        } catch (e) {}
        try {
          if (amount != null) {
            sl.get<CashWalletProvider>().getCardPaymentFundRequest();
            sl.get<CashWalletProvider>().getCashWallet();
          } else {
            await sl.get<SubscriptionProvider>().mySubscriptions();
            await sl.get<DashBoardProvider>().getCustomerDashboard();
          }
          // Toasts.showNormalToast(message.split('.').first, error: !status);
          Get.back();
          orderStatus == 1
              ? Toasts.showSuccessNormalToast(message.split('.').first)
              : Toasts.showErrorNormalToast(message.split('.').first);
        } catch (e) {
          print('buySubscription online hit failed \n $e');
        }
      }
    } catch (e) {
      print(e);
    }
    submittingCardPayment = false;
    notifyListeners();
    print('status = $status');
    return status;
  }

  Future<Map<String, dynamic>> _retrieveInvoice(String invoiceId) async {
    creatingInvoice = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    try {
      final String url = 'https://api.stripe.com/v1/invoices/$invoiceId';
      var response = await client.post(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    creatingInvoice = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> _createSubscriptions(String customerId,
      {required String priceId, String? joiningId}) async {
    creatingSubscription = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    try {
      final String url = 'https://api.stripe.com/v1/subscriptions';
      Map<String, dynamic> body = {
        'customer': customerId,
        'items[0][price]': priceId,
      };
      if (joiningId != null) {
        body.addAll({'add_invoice_items[0][price]': joiningId});
      }
      var response =
          await client.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    creatingSubscription = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> _updateCustomer(
      String paymentMethodId, String customerId) async {
    updatingCustomer = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    try {
      final String url = 'https://api.stripe.com/v1/customers/$customerId';

      var response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: {
          'invoice_settings[default_payment_method]': paymentMethodId,
        },
      );
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    updatingCustomer = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> _attachPaymentMethod(
      String paymentMethodId, String customerId) async {
    attachingPayMethod = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    try {
      final String url =
          'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
      var response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: {
          'customer': customerId,
        },
      );
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    attachingPayMethod = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> _createPaymentMethod(
      {required String number,
      required String expMonth,
      required String expYear,
      required String cvc}) async {
    creatingPayMethod = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    try {
      final String url = 'https://api.stripe.com/v1/payment_methods';
      var response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: {
          'type': 'card',
          'card[number]': '$number',
          'card[exp_month]': '$expMonth',
          'card[exp_year]': '$expYear',
          'card[cvc]': '$cvc',
        },
      );
      // print('_createPaymentMethod ${response.body} ${response.statusCode}');
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        print(json.decode(response.body));
        data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    creatingPayMethod = false;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> _createCustomer({required String name}) async {
    creatingCustomer = true;
    notifyListeners();
    Map<String, dynamic> data = {};
    UserData user = sl.get<AuthProvider>().userData;
    try {
      final String url = 'https://api.stripe.com/v1/customers';
      var response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: {
          'name': user.customerName ?? 'N/A',
          'address[country]': user.countryText ?? 'N/A',
          'email': user.customerEmail ?? '',
          // 'shipping[name]': name ?? 'N/A',
          'description': 'Subscription',
        },
      );
      // print('_createCustomer ${response.body} ${response.statusCode} ${response.statusCode}');
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        notifyListeners();
      } else {
        print(json.decode(response.body));
        var data = json.decode(response.body);
        errorText = data['error']['message'];
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    creatingCustomer = false;
    notifyListeners();
    return data;
  }

  showPaymentProcessDialog() {
    return showDialog(
        context: Get.context!,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
            onWillPop: () async => false, child: PaymentProcessDialog()));
  }
}

class PaymentProcessDialog extends StatelessWidget {
  const PaymentProcessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CardPaymentProvider>(
      builder: (context, provider, child) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: Get.width * 0.8,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      width20(),
                      (provider.makingPayment &&
                              (!provider.paymentDone ||
                                  !provider.errorOccurred))
                          ? CircularProgressIndicator(
                              color: provider.creatingCustomer
                                  ? Colors.yellow
                                  : provider.creatingPayMethod
                                      ? Colors.pink
                                      : provider.attachingPayMethod
                                          ? Colors.blue
                                          : provider.updatingCustomer
                                              ? Colors.amber
                                              : provider.creatingSubscription ||
                                                      provider.creatingIntent
                                                  ? Colors.green
                                                  : provider.creatingInvoice ||
                                                          provider
                                                              .confirmingIntent
                                                      ? Colors.pink
                                                      : Colors.white)
                          : (!provider.makingPayment && (provider.paymentDone))
                              // ? Icon(Icons.done, color: Colors.green)
                              ? SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: assetLottie(Assets.done))
                              : (!provider.makingPayment &&
                                      (provider.errorOccurred))
                                  ? Icon(Icons.error, color: Colors.red)
                                  : SizedBox(),
                      width20(),
                      Expanded(
                        child: bodyLargeText(
                            (provider.makingPayment &&
                                    provider.creatingCustomer)
                                ? provider.initialText
                                : (provider.makingPayment &&
                                        (provider.creatingPayMethod ||
                                            provider.attachingPayMethod ||
                                            provider.updatingCustomer ||
                                            provider.creatingSubscription ||
                                            provider.creatingIntent))
                                    ? provider.processText
                                    : (provider.makingPayment &&
                                                provider.creatingInvoice ||
                                            provider.confirmingIntent)
                                        ? provider.confirmText
                                        : (!provider.makingPayment &&
                                                provider.paymentDone)
                                            ? provider.successText
                                            : (!provider.makingPayment &&
                                                    provider.errorOccurred)
                                                ? provider.errorText != null
                                                    ? provider.errorText
                                                        .toString()
                                                        .split('.')
                                                        .first
                                                    : 'Something went wrong!'
                                                : '',
                            context,
                            color: (provider.makingPayment)
                                ? Colors.black
                                : (!provider.makingPayment &&
                                        provider.paymentDone)
                                    ? Colors.green
                                    : Colors.red),
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}
