class LoginLogs {
  String? deviceName;
  String? deviceName1;
  String? time;

  LoginLogs({this.deviceName, this.deviceName1, this.time});

  LoginLogs.fromJson(Map<String, dynamic> json) {
    deviceName = json['device_name'];
    deviceName1 = json['device_name1'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['device_name'] = deviceName;
    data['device_name1'] = deviceName1;
    data['time'] = time;
    return data;
  }
}
