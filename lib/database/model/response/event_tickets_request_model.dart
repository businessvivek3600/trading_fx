class EventTicketsRequests {
  String? id;
  String? orderId;
  String? customerId;
  String? username;
  String? customerName;
  String? name;
  String? image;
  String? amount;
  String? bizz;
  String? member;
  String? paymentType;
  String? transactionId;
  String? paymentUrl;
  String? paymentStatus;
  String? paypalArr;
  String? status;
  String? createdAt;

  EventTicketsRequests(
      {this.id,
      this.orderId,
      this.customerId,
      this.username,
      this.customerName,
      this.name,
      this.image,
      this.amount,
      this.bizz,
      this.member,
      this.paymentType,
      this.transactionId,
      this.paymentUrl,
      this.paymentStatus,
      this.paypalArr,
      this.status,
      this.createdAt});

  EventTicketsRequests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    username = json['username'];
    customerName = json['customer_name'];
    name = json['package_name'];
    image = json['transfer_slip'];
    amount = json["total_amount"];

    bizz = json['no_of_pin'];
    member = json['member'];
    paymentType = json['payment_type'];
    transactionId = json['transaction_id'];
    paymentUrl = json['payment_url'];
    paymentStatus = json['payment_status'];
    paypalArr = json['paypal_arr'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['username'] = username;
    data['customer_name'] = customerName;
    data['name'] = name;
    data['image'] = image;
    data['amount'] = amount;
    data['bizz'] = bizz;
    data['member'] = member;
    data['payment_type'] = paymentType;
    data['transaction_id'] = transactionId;
    data['payment_url'] = paymentUrl;
    data['payment_status'] = paymentStatus;
    data['paypal_arr'] = paypalArr;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }
}
