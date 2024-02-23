
class TeamDownlineUser {
  String? username;
  String? referral;
  int? newLevel;
  int? downline;
  int? nodeVal;
  String? status;
  String? nameWithUsername;
  String? activeDate;
  String? expireDate;
  String? totalMember;
  String? activeMember;
  bool expanded = false;
  List<TeamDownlineUser>? team;

  TeamDownlineUser({
    this.username,
    this.referral,
    this.newLevel,
    this.downline,
    this.nodeVal,
    this.status,
    this.nameWithUsername,
    this.activeDate,
    this.expireDate,
    this.totalMember,
    this.activeMember,
    this.expanded = false,
    this.team,
  });

  TeamDownlineUser.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    referral = json['referral'];
    newLevel = json['new_level'];
    nodeVal = json['nodeVal'];
    status = json['status'];
    downline = json['downline'];
    nameWithUsername = json['name_with_username'];
    activeDate = json['active_date'];
    expireDate = json['expire_date'];
    totalMember = json['total_member'];
    activeMember = json['active_member'];
    nameWithUsername='${json['customer_name']??''} ($username)';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = this.username;
    data['referral'] = this.referral;
    data['new_level'] = this.newLevel;
    data['nodeVal'] = this.nodeVal;
    data['downline'] = this.downline;
    data['status'] = this.status;
    data['name_with_username'] = this.nameWithUsername;
    data['active_date'] = this.activeDate;
    data['expire_date'] = this.expireDate;
    data['total_member'] = this.totalMember;
    data['active_member'] = this.activeMember;
    return data;
  }
}
