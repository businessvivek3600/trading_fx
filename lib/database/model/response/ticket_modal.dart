class TicketModel {
  String? ticketid;
  String? adminreplying;
  String? userid;
  String? contactid;
  String? email;
  String? name;
  String? department;
  String? priority;
  String? status;
  String? service;
  String? ticketkey;
  String? subject;
  String? message;
  String? admin;
  String? date;
  String? projectId;
  String? lastreply;
  String? clientread;
  String? adminread;
  String? ip;
  String? assigned;

  TicketModel(
      {this.ticketid,
      this.adminreplying,
      this.userid,
      this.contactid,
      this.email,
      this.name,
      this.department,
      this.priority,
      this.status,
      this.service,
      this.ticketkey,
      this.subject,
      this.message,
      this.admin,
      this.date,
      this.projectId,
      this.lastreply,
      this.clientread,
      this.adminread,
      this.ip,
      this.assigned});

  TicketModel.fromJson(Map<String, dynamic> json) {
    ticketid = json['ticketid'];
    adminreplying = json['adminreplying'];
    userid = json['userid'];
    contactid = json['contactid'];
    email = json['email'];
    name = json['name'];
    department = json['department'];
    priority = json['priority'];
    status = json['status'];
    service = json['service'];
    ticketkey = json['ticketkey'];
    subject = json['subject'];
    message = json['message'];
    admin = json['admin'];
    date = json['date'];
    projectId = json['project_id'];
    lastreply = json['lastreply'];
    clientread = json['clientread'];
    adminread = json['adminread'];
    ip = json['ip'];
    assigned = json['assigned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ticketid'] = this.ticketid;
    data['adminreplying'] = this.adminreplying;
    data['userid'] = this.userid;
    data['contactid'] = this.contactid;
    data['email'] = this.email;
    data['name'] = this.name;
    data['department'] = this.department;
    data['priority'] = this.priority;
    data['status'] = this.status;
    data['service'] = this.service;
    data['ticketkey'] = this.ticketkey;
    data['subject'] = this.subject;
    data['message'] = this.message;
    data['admin'] = this.admin;
    data['date'] = this.date;
    data['project_id'] = this.projectId;
    data['lastreply'] = this.lastreply;
    data['clientread'] = this.clientread;
    data['adminread'] = this.adminread;
    data['ip'] = this.ip;
    data['assigned'] = this.assigned;
    return data;
  }
}
