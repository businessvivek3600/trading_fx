class IncomeActivityModel {
  String? id;
  String? date;
  String? createdAt;
  String? customerId;
  String? miStatus;
  String? coin;
  String? coinEuro;
  String? amount;
  String? type;
  String? incomeTypeId;
  String? payoutId;
  String? rLeftSale;
  String? rRightSale;
  String? matchSale;
  String? username;
  String? per;
  String? reward;
  String? note;
  String? adminNote;
  String? updatedAt;

  IncomeActivityModel(
      {this.id,
      this.date,
      this.createdAt,
      this.customerId,
      this.miStatus,
      this.coin,
      this.coinEuro,
      this.amount,
      this.type,
      this.incomeTypeId,
      this.payoutId,
      this.rLeftSale,
      this.rRightSale,
      this.matchSale,
      this.username,
      this.per,
      this.reward,
      this.note,
      this.adminNote,
      this.updatedAt});

  IncomeActivityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    createdAt = json['created_at'];
    customerId = json['customer_id'];
    miStatus = json['mi_status'];
    coin = json['coin'];
    coinEuro = json['coin_euro'];
    amount = json['amount'];
    type = json['type'];
    incomeTypeId = json['income_type_id'];
    payoutId = json['payout_id'];
    rLeftSale = json['r_left_sale'];
    rRightSale = json['r_right_sale'];
    matchSale = json['match_sale'];
    username = json['username'];
    per = json['per'];
    reward = json['reward'];
    note = json['note'];
    adminNote = json['admin_note'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['created_at'] = this.createdAt;
    data['customer_id'] = this.customerId;
    data['mi_status'] = this.miStatus;
    data['coin'] = this.coin;
    data['coin_euro'] = this.coinEuro;
    data['amount'] = this.amount;
    data['type'] = this.type;
    data['income_type_id'] = this.incomeTypeId;
    data['payout_id'] = this.payoutId;
    data['r_left_sale'] = this.rLeftSale;
    data['r_right_sale'] = this.rRightSale;
    data['match_sale'] = this.matchSale;
    data['username'] = this.username;
    data['per'] = this.per;
    data['reward'] = this.reward;
    data['note'] = this.note;
    data['admin_note'] = this.adminNote;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
