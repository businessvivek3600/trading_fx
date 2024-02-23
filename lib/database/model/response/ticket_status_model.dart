class TicketStatusModel {
  String? ticketstatusid;
  String? name;
  String? isdefault;
  String? statuscolor;
  String? statusorder;

  TicketStatusModel(
      {this.ticketstatusid,
      this.name,
      this.isdefault,
      this.statuscolor,
      this.statusorder});

  TicketStatusModel.fromJson(Map<String, dynamic> json) {
    ticketstatusid = json['ticketstatusid'];
    name = json['name'];
    isdefault = json['isdefault'];
    statuscolor = json['statuscolor'];
    statusorder = json['statusorder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ticketstatusid'] = this.ticketstatusid;
    data['name'] = this.name;
    data['isdefault'] = this.isdefault;
    data['statuscolor'] = this.statuscolor;
    data['statusorder'] = this.statusorder;
    return data;
  }
}
