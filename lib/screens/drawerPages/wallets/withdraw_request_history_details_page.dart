import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/constants/app_constants.dart';
import '/providers/auth_provider.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/text.dart';
import 'package:path_provider/path_provider.dart';


import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:open_file/open_file.dart';

import '../../../database/model/response/withdraw_req_his_model.dart';
import '../../../sl_container.dart';
import '../../../utils/picture_utils.dart';

class WithdrawRequesthHistoryDetailsPage extends StatefulWidget {
  const WithdrawRequesthHistoryDetailsPage({Key? key, required this.history})
      : super(key: key);
  final WithdrawRequestHistoryModel history;
  @override
  _WithdrawRequesthHistoryDetailsPageState createState() =>
      new _WithdrawRequesthHistoryDetailsPageState();
}

class _WithdrawRequesthHistoryDetailsPageState
    extends State<WithdrawRequesthHistoryDetailsPage> {
  Future<File> createFileOfPdfUrl() async {
    final url = "http://africau.edu/images/default/sample.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              titleLargeText('Withdraw Details', context, useGradient: true)),
      body:
          Container(color: redDark, child: PDFScreen(history: widget.history)),
    );
  }
}

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key, required this.history}) : super(key: key);
  final WithdrawRequestHistoryModel history;
  @override
  PDFScreenState createState() {
    return PDFScreenState();
  }
}

class PDFScreenState extends State<PDFScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;

  PrintingInfo? printingInfo;

  var _hasData = false;
  var _pending = false;
  String? pdfFileName;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
    // askName(context).then((value) {
    //   if (value != null) {
    //     setState(() {
    _hasData = true;
    _pending = false;
    pdfFileName =
        '${(widget.history.type ?? '') + (widget.history.createdAt ?? '') + '-' + Random().nextInt(1000000000).toString()}}';
    infoLog('File Path: ${pdfFileName ?? ''}');

    // });
    // }
    // });
  }

  void _showPrintedToast(BuildContext context) {
    Fluttertoast.showToast(msg: 'File saved.');
  }

  void _showSharedToast(BuildContext context) {
    Fluttertoast.showToast(msg: 'Sharing...');
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(
        '$appDocPath/${pdfFileName ?? DateTime.now().toIso8601String()}.pdf');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(icon: const Icon(Icons.save), onPressed: _saveAsFile)
    ];

    return Center(
      child: PdfPreview(
        maxPageWidth: 800,
        build: (format) => generateInvoice(format, widget.history),
        actions: actions,
        // useActions: false,
        allowPrinting: true,
        allowSharing: true,
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
        pdfFileName: pdfFileName,
        shareActionExtraBody:
            'I hope you find this document useful in your work 👨‍💻 👩‍💻. Download the application from the givel url ${AppConstants.getDownloadUrl()}',
        shareActionExtraEmails: [
          'Download the application from the givel url ${AppConstants.getDownloadUrl()}'
        ],
        shareActionExtraSubject: 'My ${AppConstants.appName}',
        scrollViewDecoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context), fit: BoxFit.cover)),
      ),
    );
  }

  Future<String?> askName(BuildContext context) {
    return showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final controller = TextEditingController();

          return AlertDialog(
            title: const Text('Please type your name:'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            content: TextField(
              decoration: const InputDecoration(hintText: '[your name]'),
              controller: controller,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (controller.text != '') {
                    Navigator.pop(context, controller.text);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }
}

enum _PaymentType { usdtt, usdtb, bank, none }

Future<Uint8List> generateInvoice(
    PdfPageFormat pageFormat, WithdrawRequestHistoryModel history) async {
  final lorem = pw.LoremText();

  final products = <Product>[
    Product('Withdraw Amount',
        double.parse(history.amount ?? '0').toStringAsFixed(2)),
    Product(
        'Processing Charges (${double.parse(history.adminPer ?? '0').toStringAsFixed(1) + '%'})',
        double.parse(history.adminCharge ?? '0').toStringAsFixed(2)),
    // Product('28375', lorem.sentence(4), 6.95, 3),
    // Product('95673', lorem.sentence(3), 49.99, 4),
    // Product('23763', lorem.sentence(2), 560.03, 1),
    // Product('55209', lorem.sentence(5), 26, 1),
    // Product('09853', lorem.sentence(5), 26, 1),
    // Product('23463', lorem.sentence(5), 34, 1),
    // Product('56783', lorem.sentence(5), 7, 4),
    // Product('78256', lorem.sentence(5), 23, 1),
    // Product('23745', lorem.sentence(5), 94, 1),
    // Product('07834', lorem.sentence(5), 12, 1),
    // Product('23547', lorem.sentence(5), 34, 1),
    // Product('98387', lorem.sentence(5), 7.99, 2),
  ];
  var user = sl.get<AuthProvider>().userData;
  String status = history.status ?? '0';
  Color statusColor = status == '0'
      ? Colors.amber
      : status == '1'
          ? Colors.green
          : Colors.red;
  String statusText = status == '0'
      ? 'Pending'
      : status == '1'
          ? 'Approved'
          : 'Rejected';

  _PaymentType paymentType = history.paymentType == 'USDTT'
      ? _PaymentType.usdtt
      : history.paymentType == 'USDTB'
          ? _PaymentType.usdtb
          : history.paymentType == 'BANK'
              ? _PaymentType.bank
              : _PaymentType.none;
  String paymentAddress = paymentType == _PaymentType.usdtt
      ? 'USDT TRC20 Address: ${history.usdttAddress ?? ""}'
      : paymentType == _PaymentType.usdtb
          ? 'USDT BEP20 Address: ${history.usdtbAddress ?? ""}'
          : paymentType == _PaymentType.bank
              ? 'Bank: ${history.bank ?? ""}\n Account Holder Name: ${history.accountHolderName ?? ""}\n Account Number: ${history.accountNo ?? ""}\n IFSC Code: ${history.ifscCode ?? ""}'
              : "";

  final invoice = Invoice(
    history: history,
    status: statusText,
    date: _formatDate(DateTime.parse(history.createdAt ?? '0')),
    products: products,
    statusColor: statusColor,
    customerAddress:
        '${user.customerAddress1 ?? user.customerAddress2 ?? ''}\n${user.city ?? ''}, ${user.state ?? ''} ${user.zip ?? ''}\n${user.countryText ?? ''}',
    customerName: user.customerName ?? '',
    paymentInfo:
        'Payment Type: ${paymentType.name.toUpperCase()}\n${paymentAddress}',
    tax: .15,
    baseColor: PdfColor.fromInt(appLogoColor.value),
    // baseColor: PdfColors.teal,
    // accentColor: PdfColors.blueGrey900,
    accentColor: PdfColors.white,
  );

  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    required this.history,
    required this.products,
    required this.customerName,
    required this.customerAddress,
    required this.status,
    required this.date,
    required this.tax,
    required this.paymentInfo,
    required this.baseColor,
    required this.accentColor,
    required this.statusColor,
  });

  final List<Product> products;
  final String customerName;
  final String customerAddress;
  final String status;
  final Color statusColor;
  final double tax;
  final String paymentInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;
  final String date;
  final WithdrawRequestHistoryModel history;

  static const _darkColor = PdfColors.white;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

  PdfColor get _accentTextColor => baseColor.isLight ? _lightColor : _darkColor;

  pw.MemoryImage? _logo;

  pw.MemoryImage? _bgShape;
  final textColor = PdfColor.fromInt(appLogoColor.value);

  double fs1 = 12;
  double fs2 = 14;
  double fs3 = 16;
  double fs4 = 18;
  double fs5 = 20;
  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    // _logo = await rootBundle.loadString('assets/images/' + Assets.appLogo_S);
    // _bgShape = await rootBundle.loadString('assets/images/${Assets.appLogo_S}');
    try {
      _logo = pw.MemoryImage(
          (await rootBundle.load('assets/images/appLogo_s.png'))
              .buffer
              .asUint8List());
      _bgShape = pw.MemoryImage(
          (await rootBundle.load('assets/images/bgGraphic.jpg'))
              .buffer
              .asUint8List());
    } catch (e) {
      errorLog('Error: $e');
    }
    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          await PdfGoogleFonts.robotoRegular(),
          await PdfGoogleFonts.robotoBold(),
          await PdfGoogleFonts.robotoItalic(),
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          pw.SizedBox(height: 20),
          _contentHeader(context),
          pw.SizedBox(height: 20),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            //invoice texts
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  //Withdrawal Invoice text
                  pw.Container(
                    height: 50,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'Withdrawal Invoice',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: fs5 * 1.5,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.black
                          .flatten(background: PdfColor(1, 1, 1, .1)),
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 40, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 60,
                    child: pw.DefaultTextStyle(
                      style:
                          pw.TextStyle(color: _accentTextColor, fontSize: fs4),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 10,
                        children: [
                          pw.Text('Status'),
                          pw.Text(
                            status,
                            style: pw.TextStyle(
                                color: PdfColor.fromInt(statusColor.value)),
                          ),
                          pw.Text('Date:'),
                          pw.Text(date),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //logo
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                    height: 72,
                    child: _logo != null ? pw.Image(_logo!) : pw.PdfLogo(),
                  ),
                  // pw.Container(
                  //   color: baseColor,
                  //   padding: pw.EdgeInsets.only(top: 3),
                  // ),
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Divider(color: pw.GridPaper.lineColor),
        pw.Text(
          '© ${DateTime.now().year} My ${AppConstants.appName}. All Rights Reserved.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      margin: pw.EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      theme: pw.ThemeData.withFont(base: base, bold: bold, italic: italic)
          .copyWith(),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: _bgShape != null
            ? pw.Opacity(
                opacity: 0.9,
                child: pw.Image(_bgShape!, fit: pw.BoxFit.cover),
              )
            : null,
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 50,
            child: pw.FittedBox(
              child: pw.Text(
                  'Total: ${_formatCurrency(double.parse(history.amount ?? '0'))}',
                  style: pw.TextStyle(
                      color: baseColor, fontStyle: pw.FontStyle.italic)),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                height: 70,
                child: pw.RichText(
                    text: pw.TextSpan(
                        text: '$customerName\n',
                        style: pw.TextStyle(
                          color: _darkColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: fs4,
                        ),
                        children: [
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: customerAddress,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: fs3,
                        ),
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(
                    color: _darkColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: fs2),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20, bottom: 8),
                child: pw.Text(
                  'Payment Info:',
                  style: pw.TextStyle(
                      color: baseColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: fs3),
                ),
              ),
              pw.Text(
                paymentInfo,
                style: pw.TextStyle(
                  fontSize: fs1,
                  lineSpacing: 5,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Net Payable: '),
                      pw.Text(_formatCurrency(
                          double.parse(history.netPayable ?? '0'))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 30),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      top: pw.BorderSide(color: accentColor, width: .5)),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'CFO Signature',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Stamp & Signature',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 6,
                  lineSpacing: 2,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'Description',
      // 'Item Description',
      // 'Price',
      // 'Quantity',
      'Amount'
    ];

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(
          color: accentColor, width: .5, style: pw.BorderStyle.solid),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          color: baseColor),
      headerHeight: 25,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        // 1: pw.Alignment.centerLeft,
        // 2: pw.Alignment.centerRight,
        // 3: pw.Alignment.center,
        1: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
          color: _baseTextColor, fontSize: fs3, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(color: _darkColor, fontSize: fs2),
      rowDecoration: pw.BoxDecoration(
          border:
              pw.Border(bottom: pw.BorderSide(color: accentColor, width: .5))),
      headers: List<String>.generate(
          tableHeaders.length, (col) => tableHeaders[col]),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
            tableHeaders.length, (col) => products[row].getIndex(col)),
      ),
    );
  }
}

String _formatCurrency(double amount) {
  var icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  var currency = NumberFormat.currency(symbol: icon, decimalDigits: 2);
  return currency.format(amount);
}

String _formatDate(DateTime date) {
  final format = DateFormat.yMMMd('en_US');
  return format.format(date);
}

class Product {
  const Product(
    this.productName,
    this.price,
  );

  final String productName;
  final String price;

  String getIndex(int index) {
    switch (index) {
      case 0:
        // case 1:
        return productName;
      // case 2:
      //   return _formatCurrency(price);
      // case 3:
      //   return quantity.toString();
      case 1:
        return price;
    }
    return '';
  }
}
