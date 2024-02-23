class TradeIdeaModel {
  String? id;
  String? date;
  String? time;
  String? direction;
  String? market;
  String? entry;
  String? stopLoss;
  String? tP1;
  String? tP2;
  String? tP3;
  String? tP4;
  String? tP5;
  String? updates;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool? isDeleted;

  TradeIdeaModel({
    this.id,
    this.date,
    this.time,
    this.direction,
    this.market,
    this.entry,
    this.stopLoss,
    this.tP1,
    this.tP2,
    this.tP3,
    this.tP4,
    this.tP5,
    this.updates,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  TradeIdeaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    direction = json['direction'];
    market = json['market'];
    entry = json['entry'];
    stopLoss = json['stop_loss'];
    tP1 = json['TP1'];
    tP2 = json['TP2'];
    tP3 = json['TP3'];
    tP4 = json['TP4'];
    tP5 = json['TP5'];
    updates = json['updates'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['time'] = time;
    data['direction'] = direction;
    data['market'] = market;
    data['entry'] = entry;
    data['stop_loss'] = stopLoss;
    data['TP1'] = tP1;
    data['TP2'] = tP2;
    data['TP3'] = tP3;
    data['TP4'] = tP4;
    data['TP5'] = tP5;
    data['updates'] = updates;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
