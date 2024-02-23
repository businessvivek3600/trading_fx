class InboxModel {
  String? id;
  String? txnId;
  String? type;
  String? userId;
  String? title;
  String? message;
  String? status;
  String? send;
  String? cMC;
  String? file_url;
  String? createdAt;
  String? updatedAt;

  InboxModel(
      {this.id,
        this.txnId,
        this.type,
        this.userId,
        this.title,
        this.message,
        this.status,
        this.send,
        this.cMC,
        this.file_url,
        this.createdAt,
        this.updatedAt});

  InboxModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    txnId = json['txn_id'];
    type = json['type'];
    userId = json['user_id'];
    title = json['title'];
    message = json['message'];
    status = json['status'];
    send = json['send'];
    cMC = json['c_m_c'];
    file_url = json['file_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['txn_id'] = this.txnId;
    data['type'] = this.type;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['message'] = this.message;
    data['status'] = this.status;
    data['send'] = this.send;
    data['c_m_c'] = this.cMC;
    data['file_url'] = this.file_url;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
