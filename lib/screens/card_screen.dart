// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// enum CardType {
//   MasterCard,
//   Visa,
//   Verve,
//   Others, // Any other card issuer
//   Invalid // We'll use this when the card is invalid
// }
//
// class PaymentCard {
// CardType type;
// String number;
// String name;
// int month;
// int year;
// int cvv;
//
// PaymentCard(
//     {required this.type,required this.number,required this.name,required this.month,required this.year,required this.cvv});
// }
//
// class CardFieldWidget extends StatefulWidget {
//   const CardFieldWidget({Key? key}) : super(key: key);
//
//   @override
//   State<CardFieldWidget> createState() => _CardFieldWidgetState();
// }
//
// class _CardFieldWidgetState extends State<CardFieldWidget> {
//   TextEditingController numberController=TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: new Form(
//     key: _formKey,
//     autovalidate: _autoValidate,
//     child: new ListView(children: [
//
//           new TextFormField(
//           keyboardType: TextInputType.number,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             new LengthLimitingTextInputFormatter(19),
//             new CardNumberInputFormatter()
//
//           ],
//           controller: numberController,
//           decoration: new InputDecoration(
//          // suffixIcon: ,
//           icon: CardUtils.getCardIcon(_paymentCard.type),
//
//       ),
//       onSaved: (String? value) {
//         _paymentCard.number =
//             CardUtils.getCleanedNumber(value);
//       },
//       validator: CardUtils.validateCardNumWithLuhnAlgorithm,
//
//     ),
//       new TextFormField(
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           new LengthLimitingTextInputFormatter(4),
//           new CardMonthInputFormatter()
//         ],
//         decoration: new InputDecoration(
//
//
//         ),
//         validator: CardUtils.validateDate,
//         keyboardType: TextInputType.number,
//         onSaved: (value) {
//           List<int> expiryDate = CardUtils.getExpiryDate(value);
//           _paymentCard.month = expiryDate[0];
//           _paymentCard.year = expiryDate[1];
//
//         },
//       ),
//         new TextFormField(
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             new LengthLimitingTextInputFormatter(4),
//           ],
//           decoration: new InputDecoration(
//           ),
//           validator: CardUtils.validateCVV,
//           keyboardType: TextInputType.number,
//           onSaved: (value) {
//             _paymentCard.cvv = int.parse(value);
//           },
//         ),
//       ],),),
//     );
//   }
//
//   void _validateInputs() {
//     final FormState form = _formKey.currentState;
//     if (!form.validate()) {
//       setState(() {
//         _autoValidate = true; // Start validating on every change.
//       });
//       _showInSnackBar('Please fix the errors in red before submitting.');
//     } else {
//       form.save();
//       // Encrypt and send send card details to payment the gateway
//       _showInSnackBar('Payment card is valid');
//     }
//   }
//
//   void _getCardTypeFrmNumber() {
//     String input = CardUtils.getCleanedNumber(numberController.text);
//     CardType cardType = CardUtils.getCardTypeFrmNumber(input);
//     setState(() {
//       this._cardType = cardType;
//     });
//
//   }
//   static CardType getCardTypeFrmNumber(String input) {
//     CardType cardType;
//     if (input.startsWith(new RegExp(
//         r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
//       cardType = CardType.MasterCard;
//     } else if (input.startsWith(new RegExp(r'[4]'))) {
//       cardType = CardType.Visa;
//     } else if (input
//         .startsWith(new RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
//       cardType = CardType.Verve;
//     } else if (input.length <= 8) {
//       cardType = CardType.Others;
//     } else {
//       cardType = CardType.Invalid;
//     }
//     return cardType;
//   }
//   static Widget getCardIcon(CardType cardType) {
//     String img = "";
//     Icon icon;
//     switch (cardType) {
//       case CardType.MasterCard:
//         img = 'mastercard.png';
//         break;
//       case CardType.Visa:
//         img = 'visa.png';
//         break;
//       case CardType.Verve:
//         img = 'verve.png';
//         break;
//       case CardType.Others:
//         icon = new Icon(
//           Icons.credit_card,
//           size: 40.0,
//           color: Colors.grey[600],
//         );
//         break;
//       case CardType.Invalid:
//         icon = new Icon(
//           Icons.warning,
//           size: 40.0,
//           color: Colors.grey[600],
//         );
//         break;
//     }
//
//     Widget widget;
//     if (img.isNotEmpty) {
//       widget = new Image.asset(
//         'assets/images/$img',
//         width: 40.0,
//       );
//     } else {
//       widget = icon;
//     }
//     return widget;
//   }
//
//   static String validateCardNumWithLuhnAlgorithm(String input) {
//     if (input.isEmpty) {
//       return Strings.fieldReq;
//     }
//   input = getCleanedNumber(input);
//
//   if (input.length < 8) { // No need to even proceed with the validation if it's less than 8 characters
//   return Strings.numberIsInvalid;
//   }
//
//   int sum = 0;
//   int length = input.length;
//   for (var i = 0; i < length; i++) {
//   // get digits in reverse order
//   int digit = int.parse(input[length - i - 1]);
//
//   // every 2nd number multiply with 2
//   if (i % 2 == 1) {
//   digit *= 2;
//   }
//   sum += digit > 9 ? (digit - 9) : digit;
//   }
//
//   if (sum % 10 == 0) {
//   return null;
//   }
//
//   return Strings.numberIsInvalid;
// }
//   static List<int> getExpiryDate(String value) {
//     var split = value.split(new RegExp(r'(\/)'));
//     return [int.parse(split[0]), int.parse(split[1])];
//   }
// }
//
//
// class CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     var text = newValue.text;
//
//     if (newValue.selection.baseOffset == 0) {
//       return newValue;
//     }
//
//     var buffer = new StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
//         buffer.write('  '); // Add double spaces.
//       }
//     }
//
//     var string = buffer.toString();
//     return newValue.copyWith(
//         text: string,
//         selection: new TextSelection.collapsed(offset: string.length));
//   }
// }
// class CardMonthInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     var newText = newValue.text;
//
//     if (newValue.selection.baseOffset == 0) {
//       return newValue;
//     }
//
//     var buffer = new StringBuffer();
//     for (int i = 0; i < newText.length; i++) {
//       buffer.write(newText[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
//         buffer.write('/');
//       }
//     }
//     var string = buffer.toString();
//     return newValue.copyWith(
//         text: string,
//         selection: new TextSelection.collapsed(offset: string.length));
//   }
// }
//
// class CardUtils{
//   static String validateDate(String value) {
//     if (value.isEmpty) {
//       return Strings.fieldReq;
//     }
//
//     int year;
//     int month;
//     // The value contains a forward slash if the month and year has been
//     // entered.
//     if (value.contains(new RegExp(r'(\/)'))) {
//       var split = value.split(new RegExp(r'(\/)'));
//       // The value before the slash is the month while the value to right of
//       // it is the year.
//       month = int.parse(split[0]);
//       year = int.parse(split[1]);
//
//     } else { // Only the month was entered
//       month = int.parse(value.substring(0, (value.length)));
//       year = -1; // Lets use an invalid year intentionally
//     }
//
//     if ((month < 1) || (month > 12)) {
//       // A valid month is between 1 (January) and 12 (December)
//       return 'Expiry month is invalid';
//     }
//
//     var fourDigitsYear = convertYearTo4Digits(year);
//     if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
//       // We are assuming a valid year should be between 1 and 2099.
//       // Note that, it's valid doesn't mean that it has not expired.
//       return 'Expiry year is invalid';
//     }
//
//     if (!hasDateExpired(month, year)) {
//       return "Card has expired";
//     }
//     return null;
//   }
//
//
//   /// Convert the two-digit year to four-digit year if necessary
//   static int convertYearTo4Digits(int year) {
//     if (year < 100 && year >= 0) {
//       var now = DateTime.now();
//       String currentYear = now.year.toString();
//       String prefix = currentYear.substring(0, currentYear.length - 2);
//       year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
//     }
//     return year;
//   }
//
//
//   static bool hasDateExpired(int month, int year) {
//     return !(month == null || year == null) && isNotExpired(year, month);
//   }
//
//   static bool isNotExpired(int year, int month) {
//     // It has not expired if both the year and date has not passed
//     return !hasYearPassed(year) && !hasMonthPassed(year, month);
//   }
//
//   static bool hasMonthPassed(int year, int month) {
//     var now = DateTime.now();
//     // The month has passed if:
//     // 1. The year is in the past. In that case, we just assume that the month
//     // has passed
//     // 2. Card's month (plus another month) is less than current month.
//     return hasYearPassed(year) ||
//         convertYearTo4Digits(year) == now.year && (month < now.month + 1);
//   }
//
//   static bool hasYearPassed(int year) {
//     int fourDigitsYear = convertYearTo4Digits(year);
//     var now = DateTime.now();
//     // The year has passed if the year we are currently, is greater than card's
//     // year
//     return fourDigitsYear < now.year;
//   }
//
//   static String validateCVV(String value) {
//     if (value.isEmpty) {
//       return Strings.fieldReq;
//     }
//
//     if (value.length < 3 || value.length > 4) {
//       return "CVV is invalid";
//     }
//     return null;
//   }
// }
//
// class Strings {
//   static const String appName = 'Payment Card Demo';
//   static const String fieldReq = 'This field is required';
//   static const String numberIsInvalid = 'Card is invalid';
//   static const String pay = 'Validate';
//
// }