class SignUpCountry {
  String? id;
  String? sortname;
  String? name;
  String? phonecode;

  SignUpCountry({this.id, this.sortname, this.name, this.phonecode});

  SignUpCountry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sortname = json['sortname'];
    name = json['name'];
    phonecode = json['phonecode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['sortname'] = this.sortname;
    data['name'] = this.name;
    data['phonecode'] = this.phonecode;
    return data;
  }
}
