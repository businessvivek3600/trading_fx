class SubscriptionPackage {
  String? id;
  String? name;
  String? packageId;
  String? sale_type;
  String? amount;
  String? offerPrice;
  String? joiningFee;
  String? pv;
  String? productId;
  String? joiningId;
  String? d_joining_id;
  String? capping;
  String? status;
  String? image;
  String? priceId;

  SubscriptionPackage(
      {this.id,
      this.name,
      this.packageId,
      this.sale_type,
      this.d_joining_id,
      this.amount,
      this.offerPrice,
      this.joiningFee,
      this.pv,
      this.productId,
      this.joiningId,
      this.capping,
      this.status,
      this.image});

  SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    packageId = json['package_id'];
    sale_type = json['sale_type'];
    amount = json['amount'];
    offerPrice = json['offer_price'];
    joiningFee = json['joining_fee'];
    pv = json['pv'];
    productId = json['product_id'];
    joiningId = json['joining_id'];
    d_joining_id = json['d_joining_id'];
    capping = json['capping'];
    status = json['status'];
    image = json['image'];
    priceId = json['price_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['package_id'] = packageId;
    data['sale_type'] = sale_type;
    data['amount'] = amount;
    data['offer_price'] = offerPrice;
    data['joining_fee'] = joiningFee;
    data['d_joining_id'] = d_joining_id;
    data['pv'] = pv;
    data['product_id'] = productId;
    data['joining_id'] = joiningId;
    data['capping'] = capping;
    data['status'] = status;
    data['image'] = image;
    data['price_id'] = priceId;
    return data;
  }
}
