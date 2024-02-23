import '/screens/drawerPages/downlines/generation_analyzer.dart';

abstract class AbUser {
  String? id;
  String? username;
  int? nodeValue;
  int? newLevel;

  AbUser({this.id, this.username, this.nodeValue, this.newLevel});
}

//Matrix User Model

class MatrixUser extends AbUser with BreadCrumbData {
  String? id;
  String? username;
  String? customerId;
  String? customerName;
  String? directSponserUsername;
  String? sponserUsername;
  String? position;
  String? salesActive;
  String? placed;
  String? status;
  String? downFull;
  String? autoPlace;
  String? apIncrement;
  String? createdAt;
  List<MatrixUser>? team;

  MatrixUser({
    this.id,
    this.username,
    int? nodeValue,
    int? newLevel,
    this.customerId,
    this.customerName,
    this.directSponserUsername,
    this.sponserUsername,
    this.position,
    this.salesActive,
    this.placed,
    this.status,
    this.downFull,
    this.autoPlace,
    this.apIncrement,
    this.createdAt,
    this.team,
  }) : super(
            id: id,
            username: username,
            nodeValue: nodeValue,
            newLevel: newLevel);

  MatrixUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    username = json['username'];
    customerName = json['customer_name'];
    directSponserUsername = json['direct_sponser_username'];
    sponserUsername = json['sponser_username'];
    position = json['position'];
    salesActive = json['sales_active'];
    placed = json['placed'];
    status = json['sales_active'];
    downFull = json['down_full'];
    autoPlace = json['auto_place'];
    apIncrement = json['ap_increment'];
    createdAt = json['created_at'];
    if (json['team_member'] != null) {
      team = <MatrixUser>[];
      json['team_member'].forEach((v) {
        team!.add(new MatrixUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['username'] = this.username;
    data['customer_name'] = this.customerName;
    data['direct_sponser_username'] = this.directSponserUsername;
    data['sponser_username'] = this.sponserUsername;
    data['position'] = this.position;
    data['sales_active'] = this.salesActive;
    data['new_level'] = this.newLevel;
    data['node_value'] = this.nodeValue;
    data['placed'] = this.placed;
    data['sales_active'] = this.status;
    data['down_full'] = this.downFull;
    data['auto_place'] = this.autoPlace;
    data['ap_increment'] = this.apIncrement;
    data['created_at'] = this.createdAt;
    if (this.team != null) {
      data['team_member'] = this.team!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
