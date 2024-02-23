class DownloadFilesModel {
  String? id;
  String? language;
  String? text;
  String? link;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;

  DownloadFilesModel(
      {this.id,
      this.language,
      this.text,
      this.link,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt});

  DownloadFilesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    language = json['language'];
    text = json['text'];
    link = json['link'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['language'] = this.language;
    data['text'] = this.text;
    data['link'] = this.link;
    data['image'] = this.image;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
