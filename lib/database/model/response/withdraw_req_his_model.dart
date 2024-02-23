class WithdrawRequestHistoryModel {
  String? id;
  String? date;
  String? type;
  String? customerId;
  String? username;
  String? name;
  String? accountHolderName;
  String? accountNo;
  String? ifscCode;
  String? bank;
  String? usdtbAddress;
  String? usdttAddress;
  String? amount;
  String? minBal;
  String? adminPer;
  String? adminCharge;
  String? tdsPer;
  String? tdsCharge;
  String? repurchasedPer;
  String? repurchasedCharge;
  String? offerAmt;
  String? netPayable;
  String? coinPrice;
  String? netCoinPrice;
  String? paymentType;
  String? country;
  String? currency;
  String? currencyAmt;
  String? transactionNumber;
  String? status;
  String? remarks;
  String? ipAddress;
  String? createdAt;
  String? updatedAt;

  WithdrawRequestHistoryModel(
      {this.id,
      this.date,
      this.type,
      this.customerId,
      this.username,
      this.name,
      this.accountHolderName,
      this.accountNo,
      this.ifscCode,
      this.bank,
      this.usdtbAddress,
      this.usdttAddress,
      this.amount,
      this.minBal,
      this.adminPer,
      this.adminCharge,
      this.tdsPer,
      this.tdsCharge,
      this.repurchasedPer,
      this.repurchasedCharge,
      this.offerAmt,
      this.netPayable,
      this.coinPrice,
      this.netCoinPrice,
      this.paymentType,
      this.country,
      this.currency,
      this.currencyAmt,
      this.transactionNumber,
      this.status,
      this.remarks,
      this.ipAddress,
      this.createdAt,
      this.updatedAt});

  WithdrawRequestHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    type = json['type'];
    customerId = json['customer_id'];
    username = json['username'];
    name = json['name'];
    accountHolderName = json['account_holder_name'];
    accountNo = json['account_no'];
    ifscCode = json['ifsc_code'];
    bank = json['bank'];
    usdtbAddress = json['usdtb_address'];
    usdttAddress = json['usdtt_address'];
    amount = json['amount'];
    minBal = json['min_bal'];
    adminPer = json['admin_per'];
    adminCharge = json['admin_charge'];
    tdsPer = json['tds_per'];
    tdsCharge = json['tds_charge'];
    repurchasedPer = json['repurchased_per'];
    repurchasedCharge = json['repurchased_charge'];
    offerAmt = json['offer_amt'];
    netPayable = json['net_payable'];
    coinPrice = json['coin_price'];
    netCoinPrice = json['net_coin_price'];
    paymentType = json['payment_type'];
    country = json['country'];
    currency = json['currency'];
    currencyAmt = json['currency_amt'];
    transactionNumber = json['transaction_number'];
    status = json['status'];
    remarks = json['remarks'];
    ipAddress = json['ip_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['type'] = this.type;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['name'] = this.name;
    data['account_holder_name'] = this.accountHolderName;
    data['account_no'] = this.accountNo;
    data['ifsc_code'] = this.ifscCode;
    data['bank'] = this.bank;
    data['usdtb_address'] = this.usdtbAddress;
    data['usdtt_address'] = this.usdttAddress;
    data['amount'] = this.amount;
    data['min_bal'] = this.minBal;
    data['admin_per'] = this.adminPer;
    data['admin_charge'] = this.adminCharge;
    data['tds_per'] = this.tdsPer;
    data['tds_charge'] = this.tdsCharge;
    data['repurchased_per'] = this.repurchasedPer;
    data['repurchased_charge'] = this.repurchasedCharge;
    data['offer_amt'] = this.offerAmt;
    data['net_payable'] = this.netPayable;
    data['coin_price'] = this.coinPrice;
    data['net_coin_price'] = this.netCoinPrice;
    data['payment_type'] = this.paymentType;
    data['country'] = this.country;
    data['currency'] = this.currency;
    data['currency_amt'] = this.currencyAmt;
    data['transaction_number'] = this.transactionNumber;
    data['status'] = this.status;
    data['remarks'] = this.remarks;
    data['ip_address'] = this.ipAddress;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
