class VideoCategoryModel {
  String? id;
  String? language;
  String? position;
  String? header;
  String? content;
  String? status;
  String? pack500;
  String? pack2000;
  String? pack5000;
  String? createdAt;
  String? updatedAt;
  List<CategoryVideo>? videoList;

  VideoCategoryModel(
      {this.id,
        this.language,
        this.position,
        this.header,
        this.content,
        this.status,
        this.pack500,
        this.pack2000,
        this.pack5000,
        this.createdAt,
        this.updatedAt,
        this.videoList});

  VideoCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    language = json['language'];
    position = json['position'];
    header = json['header'];
    content = json['content'];
    status = json['status'];
    pack500 = json['pack_500'];
    pack2000 = json['pack_2000'];
    pack5000 = json['pack_5000'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['video_list'] != null) {
      videoList = <CategoryVideo>[];
      json['video_list'].forEach((v) {
        videoList!.add(new CategoryVideo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['language'] = this.language;
    data['position'] = this.position;
    data['header'] = this.header;
    data['content'] = this.content;
    data['status'] = this.status;
    data['pack_500'] = this.pack500;
    data['pack_2000'] = this.pack2000;
    data['pack_5000'] = this.pack5000;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.videoList != null) {
      data['video_list'] = this.videoList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryVideo {
  String? id;
  String? academicVideosId;
  String? title;
  String? videoBanner;
  String? videoUrl;
  String? status;
  String? createdAt;
  String? updatedAt;

  CategoryVideo(
      {this.id,
        this.academicVideosId,
        this.title,
        this.videoBanner,
        this.videoUrl,
        this.status,
        this.createdAt,
        this.updatedAt});

  CategoryVideo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    academicVideosId = json['academic_videos_id'];
    title = json['title'];
    videoBanner = json['video_banner'];
    videoUrl = json['video_url'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['academic_videos_id'] = this.academicVideosId;
    data['title'] = this.title;
    data['video_banner'] = this.videoBanner;
    data['video_url'] = this.videoUrl;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
