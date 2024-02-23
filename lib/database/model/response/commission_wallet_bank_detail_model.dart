class CommissionWalletBankDetail {
  String? id;
  String? customerId;
  String? customerUsername;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? bank;
  String? branch;
  String? bankcode;
  String? address;
  String? city;
  String? state;
  String? btcAddress;
  String? usdttAddress;
  String? usdtbAddress;
  String? status;
  String? ipAddress;
  String? createdAt;
  String? updatedAt;

  CommissionWalletBankDetail(
      {this.id,
      this.customerId,
      this.customerUsername,
      this.accountHolderName,
      this.accountNumber,
      this.ifscCode,
      this.bank,
      this.branch,
      this.bankcode,
      this.address,
      this.city,
      this.state,
      this.btcAddress,
      this.usdttAddress,
      this.usdtbAddress,
      this.status,
      this.ipAddress,
      this.createdAt,
      this.updatedAt});

  CommissionWalletBankDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    customerUsername = json['customer_username'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    ifscCode = json['ifsc_code'];
    bank = json['bank'];
    branch = json['branch'];
    bankcode = json['bankcode'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    btcAddress = json['btc_address'];
    usdttAddress = json['usdtt_address'];
    usdtbAddress = json['usdtb_address'];
    status = json['status'];
    ipAddress = json['ip_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['customer_username'] = this.customerUsername;
    data['account_holder_name'] = this.accountHolderName;
    data['account_number'] = this.accountNumber;
    data['ifsc_code'] = this.ifscCode;
    data['bank'] = this.bank;
    data['branch'] = this.branch;
    data['bankcode'] = this.bankcode;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['btc_address'] = this.btcAddress;
    data['usdtt_address'] = this.usdttAddress;
    data['usdtb_address'] = this.usdtbAddress;
    data['status'] = this.status;
    data['ip_address'] = this.ipAddress;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
