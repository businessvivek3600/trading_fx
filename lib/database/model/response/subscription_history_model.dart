class SubscriptionHistory {
  String? id;
  String? orderId;
  String? createdAt;
  String? expiredAt;
  String? customerId;
  String? username;
  String? paymentType;
  String? epin;
  String? noOfTrade;
  String? tradePrice;
  String? totalAmount;
  Null? note;
  String? status;
  String? nextDate;
  String? updatedAt;
  String? cancelDate;
  String? uL;

  SubscriptionHistory(
      {this.id,
      this.orderId,
      this.createdAt,
      this.expiredAt,
      this.customerId,
      this.username,
      this.paymentType,
      this.epin,
      this.noOfTrade,
      this.tradePrice,
      this.totalAmount,
      this.note,
      this.status,
      this.nextDate,
      this.updatedAt,
      this.cancelDate,
      this.uL});

  SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    createdAt = json['created_at'];
    expiredAt = json['expired_at'];
    customerId = json['customer_id'];
    username = json['username'];
    paymentType = json['payment_type'];
    epin = json['epin'];
    noOfTrade = json['no_of_trade'];
    tradePrice = json['trade_price'];
    totalAmount = json['total_amount'];
    note = json['note'];
    status = json['status'];
    nextDate = json['next_date'];
    updatedAt = json['updated_at'];
    cancelDate = json['cancel_date'];
    uL = json['u_l'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['created_at'] = createdAt;
    data['expired_at'] = expiredAt;
    data['customer_id'] = customerId;
    data['username'] = username;
    data['payment_type'] = paymentType;
    data['epin'] = epin;
    data['no_of_trade'] = noOfTrade;
    data['trade_price'] = tradePrice;
    data['total_amount'] = totalAmount;
    data['note'] = note;
    data['status'] = status;
    data['next_date'] = nextDate;
    data['updated_at'] = updatedAt;
    data['cancel_date'] = cancelDate;
    data['u_l'] = uL;
    return data;
  }
}
