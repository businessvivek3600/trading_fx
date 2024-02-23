class OffersModel {
  String? id;
  String? title;
  String? file;
  String? status;
  String? updatedAt;
  String? createdAt;

  OffersModel(
      {this.id,
        this.title,
        this.file,
        this.status,
        this.updatedAt,
        this.createdAt});

  OffersModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    file = json['file'];
    status = json['status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['file'] = this.file;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    return data;
  }
}
