class CustomerReward {
  String? id;
  String? name;
  String? pair;
  String? sumPair;
  String? requireCondition;
  String? amount;
  String? reward;
  String? image;

  CustomerReward(
      {this.id,
      this.name,
      this.pair,
      this.sumPair,
      this.requireCondition,
      this.amount,
      this.reward,
      this.image});

  CustomerReward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pair = json['pair'];
    sumPair = json['sum_pair'];
    requireCondition = json['require_condition'];
    amount = json['amount'];
    reward = json['reward'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['pair'] = this.pair;
    data['sum_pair'] = this.sumPair;
    data['require_condition'] = this.requireCondition;
    data['amount'] = this.amount;
    data['reward'] = this.reward;
    data['image'] = this.image;
    return data;
  }
}
