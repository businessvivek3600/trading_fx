class CardDetailsPurchasedHistoryModel {
  String? id;
  String? orderId;
  String? type;
  String? customerId;
  String? username;
  String? customerEmail;
  String? firstName;
  String? lastName;
  String? phoneNo;
  String? address;
  String? quantity;
  String? currency;
  String? amount;
  String? paymentType;
  String? transactionId;
  String? paymentUrl;
  String? paymentStatus;
  String? paypalArr;
  String? status;
  String? deliveryStatus;
  String? deliveryType;
  String? createdAt;
  String? updatedAt;

  CardDetailsPurchasedHistoryModel(
      {this.id,
      this.orderId,
      this.type,
      this.customerId,
      this.username,
      this.customerEmail,
      this.firstName,
      this.lastName,
      this.phoneNo,
      this.address,
      this.quantity,
      this.currency,
      this.amount,
      this.paymentType,
      this.transactionId,
      this.paymentUrl,
      this.paymentStatus,
      this.paypalArr,
      this.status,
      this.deliveryStatus,
      this.deliveryType,
      this.createdAt,
      this.updatedAt});

  CardDetailsPurchasedHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    type = json['type'];
    customerId = json['customer_id'];
    username = json['username'];
    customerEmail = json['customer_email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phoneNo = json['phone_no'];
    address = json['address'];
    quantity = json['quantity'];
    currency = json['currency'];
    amount = json['amount'];
    paymentType = json['payment_type'];
    transactionId = json['transaction_id'];
    paymentUrl = json['payment_url'];
    paymentStatus = json['payment_status'];
    paypalArr = json['paypal_arr'];
    status = json['status'];
    deliveryStatus = json['delivery_status'];
    deliveryType = json['delivery_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['type'] = this.type;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['customer_email'] = this.customerEmail;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone_no'] = this.phoneNo;
    data['address'] = this.address;
    data['quantity'] = this.quantity;
    data['currency'] = this.currency;
    data['amount'] = this.amount;
    data['payment_type'] = this.paymentType;
    data['transaction_id'] = this.transactionId;
    data['payment_url'] = this.paymentUrl;
    data['payment_status'] = this.paymentStatus;
    data['paypal_arr'] = this.paypalArr;
    data['status'] = this.status;
    data['delivery_status'] = this.deliveryStatus;
    data['delivery_type'] = this.deliveryType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
