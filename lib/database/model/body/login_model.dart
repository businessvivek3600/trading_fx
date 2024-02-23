class LoginModel {
  String? device_id;
  String? username;
  String? password;
  String? device_name;

  LoginModel({
    required this.device_id,
    required this.username,
    required this.password,
    this.device_name,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    device_id = json['device_id'];
    username = json['username'];
    password = json['password'];
    device_name = json['device_info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['device_id'] = device_id;
    data['username'] = username;
    data['password'] = password;
    data['device_name'] = device_name;
    return data;
  }
}
