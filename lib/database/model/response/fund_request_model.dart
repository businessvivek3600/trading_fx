class FundRequestModel {
  String? id;
  String? orderId;
  String? createdAt;
  String? customerId;
  String? username;
  String? amount;
  String? paymentType;
  String? paymentUrl;
  String? txnId;
  String? status;
  String? note;
  String? updatedAt;

  FundRequestModel(
      {this.id,
      this.orderId,
      this.createdAt,
      this.customerId,
      this.username,
      this.amount,
      this.paymentType,
      this.paymentUrl,
      this.txnId,
      this.status,
      this.note,
      this.updatedAt});

  FundRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    createdAt = json['created_at'];
    customerId = json['customer_id'];
    username = json['username'];
    amount = json['amount'];
    paymentType = json['payment_type'];
    paymentUrl = json['payment_url'];
    txnId = json['txn_id'];
    status = json['status'];
    note = json['note'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['created_at'] = this.createdAt;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['amount'] = this.amount;
    data['payment_type'] = this.paymentType;
    data['payment_url'] = this.paymentUrl;
    data['txn_id'] = this.txnId;
    data['status'] = this.status;
    data['note'] = this.note;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
