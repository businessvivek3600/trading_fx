class GetActiveLegModel {
  String? username;
  String? status;
  String? member;
  String? active_Member;
  String? activeMember;

  GetActiveLegModel(
      {this.username,
      this.status,
      this.member,
      this.active_Member,
      this.activeMember});

  GetActiveLegModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    status = json['status'];
    member = json['member'];
    active_Member = json['active_member'];
    activeMember = json['activeMember'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['status'] = this.status;
    data['member'] = this.member;
    data['active_member'] = this.active_Member;
    data['activeMember'] = this.activeMember;
    return data;
  }
}
