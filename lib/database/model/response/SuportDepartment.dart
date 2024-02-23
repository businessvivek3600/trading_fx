class SupportDepartment {
  String? departmentid;
  String? name;
  String? imapUsername;
  String? email;
  String? emailFromHeader;
  String? host;
  String? password;
  String? encryption;
  String? deleteAfterImport;
  String? calendarId;
  String? hidefromclient;

  SupportDepartment(
      {this.departmentid,
      this.name,
      this.imapUsername,
      this.email,
      this.emailFromHeader,
      this.host,
      this.password,
      this.encryption,
      this.deleteAfterImport,
      this.calendarId,
      this.hidefromclient});

  SupportDepartment.fromJson(Map<String, dynamic> json) {
    departmentid = json['departmentid'];
    name = json['name'];
    imapUsername = json['imap_username'];
    email = json['email'];
    emailFromHeader = json['email_from_header'];
    host = json['host'];
    password = json['password'];
    encryption = json['encryption'];
    deleteAfterImport = json['delete_after_import'];
    calendarId = json['calendar_id'];
    hidefromclient = json['hidefromclient'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['departmentid'] = this.departmentid;
    data['name'] = this.name;
    data['imap_username'] = this.imapUsername;
    data['email'] = this.email;
    data['email_from_header'] = this.emailFromHeader;
    data['host'] = this.host;
    data['password'] = this.password;
    data['encryption'] = this.encryption;
    data['delete_after_import'] = this.deleteAfterImport;
    data['calendar_id'] = this.calendarId;
    data['hidefromclient'] = this.hidefromclient;
    return data;
  }
}
