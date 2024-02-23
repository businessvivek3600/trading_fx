class VoucherModel {
  String? id;
  String? epin;
  String? noOfTrade;
  String? packageId;
  String? packageName;
  String? packageAmt;
  String? totalAmount;
  String? allotedBy;
  String? usedBy;
  String? transferredBy;
  String? block;
  String? expire;
  String? note;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  String? bp;

  VoucherModel(
      {this.id,
      this.epin,
      this.noOfTrade,
      this.packageId,
      this.packageName,
      this.packageAmt,
      this.totalAmount,
      this.allotedBy,
      this.usedBy,
      this.transferredBy,
      this.block,
      this.expire,
      this.note,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.bp});

  VoucherModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    epin = json['epin'];
    noOfTrade = json['no_of_trade'];
    packageId = json['package_id'];
    packageName = json['package_name'];
    packageAmt = json['package_amt'];
    totalAmount = json['total_amount'];
    allotedBy = json['alloted_by'];
    usedBy = json['used_by'];
    transferredBy = json['transferred_by'];
    block = json['block'];
    expire = json['expire'];
    note = json['note'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bp = json['bp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['epin'] = this.epin;
    data['no_of_trade'] = this.noOfTrade;
    data['package_id'] = this.packageId;
    data['package_name'] = this.packageName;
    data['package_amt'] = this.packageAmt;
    data['total_amount'] = this.totalAmount;
    data['alloted_by'] = this.allotedBy;
    data['used_by'] = this.usedBy;
    data['transferred_by'] = this.transferredBy;
    data['block'] = this.block;
    data['expire'] = this.expire;
    data['note'] = this.note;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['bp'] = this.bp;
    return data;
  }
}
