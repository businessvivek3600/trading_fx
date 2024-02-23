import 'dart:developer';

class VoucherPackageModel {
  String? id;
  String? currency;
  String? saleType;
  String? packageId;
  String? name;
  int max = 0;
  String? amount;
  String? productId;
  String? joiningId;
  String? status;
  String? image;
  String? giftImg;

  VoucherPackageModel(
      {this.id,
      this.currency,
      this.saleType,
      this.packageId,
      this.name,
      this.max = 0,
      this.amount,
      this.productId,
      this.joiningId,
      this.status,
      this.image,
      this.giftImg});

  VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    saleType = json['sale_type'];
    packageId = json['package_id'];
    name = json['name'];
    max = int.tryParse(json['max'].toString()) ?? 0;
    amount = json['amount'];
    productId = json['product_id'];
    joiningId = json['joining_id'];
    status = json['status'];
    image = json['image'];
    giftImg = json['gift_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['currency'] = currency;
    data['sale_type'] = saleType;
    data['package_id'] = packageId;
    data['name'] = name;
    data['pack_amt'] = max;
    data['amount'] = amount;
    data['product_id'] = productId;
    data['joining_id'] = joiningId;
    data['status'] = status;
    data['image'] = image;
    data['gift_img'] = giftImg;
    return data;
  }
}
