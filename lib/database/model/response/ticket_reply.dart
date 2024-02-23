class TicketReply {
  String? id;
  String? ip;
  String? fromName;
  String? replyEmail;
  String? admin;
  String? userid;
  String? message;
  String? date;
  String? contactid;
  String? submitter;
  List<Attachment>? attachments;

  TicketReply(
      {this.id,
      this.ip,
      this.fromName,
      this.replyEmail,
      this.admin,
      this.userid,
      this.message,
      this.date,
      this.contactid,
      this.submitter,
      this.attachments});

  TicketReply.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ip = json['ip'];
    fromName = json['from_name'];
    replyEmail = json['reply_email'];
    admin = json['admin'];
    userid = json['userid'];
    message = json['message'];
    date = json['date'];
    contactid = json['contactid'];
    submitter = json['submitter'];
    if (json['attachments'] != null) {
      attachments = <Attachment>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['ip'] = this.ip;
    data['from_name'] = this.fromName;
    data['reply_email'] = this.replyEmail;
    data['admin'] = this.admin;
    data['userid'] = this.userid;
    data['message'] = this.message;
    data['date'] = this.date;
    data['contactid'] = this.contactid;
    data['submitter'] = this.submitter;
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachment {
  String? id;
  String? ticketid;
  String? replyid;
  String? fileName;
  String? filetype;
  String? dateadded;

  Attachment(
      {this.id,
      this.ticketid,
      this.replyid,
      this.fileName,
      this.filetype,
      this.dateadded});

  Attachment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketid = json['ticketid'];
    replyid = json['replyid'];
    fileName = json['file_name'];
    filetype = json['filetype'];
    dateadded = json['dateadded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticketid'] = this.ticketid;
    data['replyid'] = this.replyid;
    data['file_name'] = this.fileName;
    data['filetype'] = this.filetype;
    data['dateadded'] = this.dateadded;
    return data;
  }
}
