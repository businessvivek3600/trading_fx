class CashWalletHistory {
  String? id;
  String? date;
  String? payoutId;
  String? customerId;
  String? balance;
  String? debit;
  String? credit;
  String? note;
  String? createdBy;
  String? createdAt;

  CashWalletHistory(
      {this.id,
      this.date,
      this.payoutId,
      this.customerId,
      this.balance,
      this.debit,
      this.credit,
      this.note,
      this.createdBy,
      this.createdAt});

  CashWalletHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    payoutId = json['payout_id'];
    customerId = json['customer_id'];
    balance = json['balance'];
    debit = json['debit'];
    credit = json['credit'];
    note = json['note'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['date'] = this.date;
    data['payout_id'] = this.payoutId;
    data['customer_id'] = this.customerId;
    data['balance'] = this.balance;
    data['debit'] = this.debit;
    data['credit'] = this.credit;
    data['note'] = this.note;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    return data;
  }
}
