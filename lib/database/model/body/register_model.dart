class RegisterModel {
  String? device_id;
  String? username;
  String? email;
  String? password;
  String? fName;
  String? lName;
  String? phone;
  String? spassword;
  String? confirm_password;
  String? sponser_username;
  String? placement_username;
  String? country_code;
  String? device_name;

  RegisterModel({
    this.device_id,
    this.username,
    this.email,
    this.password,
    this.fName,
    this.lName,
    this.phone,
    this.spassword,
    this.confirm_password,
    this.sponser_username,
    this.placement_username,
    this.country_code,
    this.device_name,
  });

  RegisterModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['customer_email'];
    fName = json['first_name'];
    lName = json['last_name'];
    spassword = json['spassword'];
    confirm_password = json['confirm_password'];
    phone = json['customer_mobile'];
    email = json['customer_email'];
    sponser_username = json['sponser_username'];
    placement_username = json['placement_username'];
    country_code = json['country_code'];
    device_id = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['device_id'] = device_id;
    data['customer_email'] = email;
    data['username'] = username;
    data['spassword'] = password;
    data['first_name'] = fName;
    data['last_name'] = lName;
    data['customer_mobile'] = phone;
    data['spassword'] = spassword;
    data['confirm_password'] = confirm_password;
    data['sponser_username'] = sponser_username;
    data['placement_username'] = placement_username;
    data['country_code'] = country_code ?? '';
    data['device_name'] = device_name;
    return data;
  }
}
