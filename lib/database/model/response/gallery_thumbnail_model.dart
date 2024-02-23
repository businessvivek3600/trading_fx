class GalleryThumbnailModel {
  String? id;
  String? header;
  String? defaultImage;
  String? images;
  String? status;
  String? createdAt;
  String? updatedAt;

  GalleryThumbnailModel(
      {this.id,
        this.header,
        this.defaultImage,
        this.images,
        this.status,
        this.createdAt,
        this.updatedAt});

  GalleryThumbnailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    header = json['header'];
    defaultImage = json['default_image'];
    images = json['images'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['header'] = this.header;
    data['default_image'] = this.defaultImage;
    data['images'] = this.images;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
