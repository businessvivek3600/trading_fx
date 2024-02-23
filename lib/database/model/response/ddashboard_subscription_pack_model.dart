class DashboardSubscriptionPack {
  String? id;
  String? invoice;
  String? invoiceId;
  String? createdAt;
  String? expiredAt;
  String? customerId;
  String? username;
  String? packageId;
  String? packageAmount;
  String? packageName;
  String? payableAmt;
  String? epin;
  String? paymentType;
  String? txnId;
  String? stripeSubId;
  String? stripeInvNo;
  String? stripeDetail;
  String? status;
  String? note;
  String? dI;
  String? updatedAt;

  DashboardSubscriptionPack(
      {this.id,
      this.invoice,
      this.invoiceId,
      this.createdAt,
      this.expiredAt,
      this.customerId,
      this.username,
      this.packageId,
      this.packageAmount,
      this.packageName,
      this.payableAmt,
      this.epin,
      this.paymentType,
      this.txnId,
      this.stripeSubId,
      this.stripeInvNo,
      this.stripeDetail,
      this.status,
      this.note,
      this.dI,
      this.updatedAt});

  DashboardSubscriptionPack.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoice = json['invoice'];
    invoiceId = json['invoice_id'];
    createdAt = json['created_at'];
    expiredAt = json['expired_at'];
    customerId = json['customer_id'];
    username = json['username'];
    packageId = json['package_id'];
    packageAmount = json['package_amount'];
    packageName = json['package_name'];
    payableAmt = json['payable_amt'];
    epin = json['epin'];
    paymentType = json['payment_type'];
    txnId = json['txn_id'];
    stripeSubId = json['stripe_sub_id'];
    stripeInvNo = json['stripe_inv_no'];
    stripeDetail = json['stripe_detail'];
    status = json['status'];
    note = json['note'];
    dI = json['d_i'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['invoice'] = this.invoice;
    data['invoice_id'] = this.invoiceId;
    data['created_at'] = this.createdAt;
    data['expired_at'] = this.expiredAt;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['package_id'] = this.packageId;
    data['package_amount'] = this.packageAmount;
    data['package_name'] = this.packageName;
    data['payable_amt'] = this.payableAmt;
    data['epin'] = this.epin;
    data['payment_type'] = this.paymentType;
    data['txn_id'] = this.txnId;
    data['stripe_sub_id'] = this.stripeSubId;
    data['stripe_inv_no'] = this.stripeInvNo;
    data['stripe_detail'] = this.stripeDetail;
    data['status'] = this.status;
    data['note'] = this.note;
    data['d_i'] = this.dI;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
