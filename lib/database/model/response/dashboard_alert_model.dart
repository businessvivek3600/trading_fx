class DashboardAlert {
  String? info;
  String? action;
  int? status;
  String? type;
  String? url;

  DashboardAlert({this.info, this.action, this.status, this.type, this.url});

  DashboardAlert.fromJson(Map<String, dynamic> json) {
    info = json['info'];
    action = json['action'];
    status = json['status'];
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['info'] = info;
    data['action'] = action;
    data['status'] = status;
    data['type'] = type;
    data['url'] = url;
    return data;
  }
}
