class CardFeatureDetail {
  int? id;
  String? name;
  String? image;
  bool free = false;
  double? discountPer;
  int? price;
  Map<String, dynamic>? paymentType = {};
  List<Delivery>? delivery;

  CardFeatureDetail(
      {this.id,
      this.name,
      this.image,
      this.free = false,
      this.discountPer,
      this.price,
      this.paymentType,
      this.delivery});

  CardFeatureDetail.fromJson(Map<String, dynamic> json) {
    print(json);
    id = json['id'];
    name = json['name'];
    image = json['image'];
    free = json['free'];
    discountPer = (json['discount_per'] ?? 0.0).toDouble();
    price = json['price'];
    json['payment_type'] != null
        ? paymentType!.addAll(json['payment_type'])
        : {};
    if (json['delivery'] != null) {
      delivery = <Delivery>[];
      json['delivery'].forEach((v) {
        delivery!.add(new Delivery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['free'] = this.free;
    data['discount_per'] = this.discountPer;
    data['price'] = this.price;
    if (this.paymentType != null) {
      data['payment_type'] = this.paymentType;
    }
    if (this.delivery != null) {
      data['delivery'] = this.delivery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentType {
  String? walletCH;
  String? walletCM;
  String? uSDTBEP20;
  String? uSDTTRC20;
  String? bTC;

  PaymentType(
      {this.walletCH, this.walletCM, this.uSDTBEP20, this.uSDTTRC20, this.bTC});

  PaymentType.fromJson(Map<String, dynamic> json) {
    walletCH = json['Wallet-CH'];
    walletCM = json['Wallet-CM'];
    uSDTBEP20 = json['USDT-BEP20'];
    uSDTTRC20 = json['USDT-TRC20'];
    bTC = json['BTC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Wallet-CH'] = this.walletCH;
    data['Wallet-CM'] = this.walletCM;
    data['USDT-BEP20'] = this.uSDTBEP20;
    data['USDT-TRC20'] = this.uSDTTRC20;
    data['BTC'] = this.bTC;
    return data;
  }
}

class Delivery {
  String? name;
  int? price;

  Delivery({this.name, this.price});

  Delivery.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
