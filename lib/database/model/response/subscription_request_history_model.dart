class SubscriptionRequestHistory {
  String? id;
  String? orderId;
  String? customerId;
  String? username;
  String? paymentType;
  String? packageId;
  String? packageName;
  String? packageAmount;
  String? saleType;
  String? totalAmount;
  String? coupan;
  String? transactionId;
  String? paymentUrl;
  String? status;
  String? paymentHistory;
  String? createdAt;
  String? updatedAt;

  SubscriptionRequestHistory(
      {this.id,
      this.orderId,
      this.customerId,
      this.username,
      this.paymentType,
      this.packageId,
      this.packageName,
      this.packageAmount,
      this.saleType,
      this.totalAmount,
      this.coupan,
      this.transactionId,
      this.paymentUrl,
      this.status,
      this.paymentHistory,
      this.createdAt,
      this.updatedAt});

  SubscriptionRequestHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    username = json['username'];
    paymentType = json['payment_type'];
    packageId = json['package_id'];
    packageName = json['package_name'];
    packageAmount = json['package_amount'];
    saleType = json['sale_type'];
    totalAmount = json['total_amount'];
    coupan = json['coupan'];
    transactionId = json['transaction_id'];
    paymentUrl = json['payment_url'];
    status = json['status'];
    paymentHistory = json['payment_history'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['payment_type'] = this.paymentType;
    data['package_id'] = this.packageId;
    data['package_name'] = this.packageName;
    data['package_amount'] = this.packageAmount;
    data['sale_type'] = this.saleType;
    data['total_amount'] = this.totalAmount;
    data['coupan'] = this.coupan;
    data['transaction_id'] = this.transactionId;
    data['payment_url'] = this.paymentUrl;
    data['status'] = this.status;
    data['payment_history'] = this.paymentHistory;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
