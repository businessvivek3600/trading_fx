class WebinarEventModel {
  String? settingId;
  String? webinarTitle;
  String? webinarDesc;
  String? webinarTime;
  String? webinarId;
  String? vimeoWebinarId;
  String? status;
  String? webinarChat;
  String? createdAt;
  String? updatedAt;

  WebinarEventModel(
      {this.settingId,
      this.webinarTitle,
      this.webinarDesc,
      this.webinarTime,
      this.webinarId,
      this.vimeoWebinarId,
      this.status,
      this.webinarChat,
      this.createdAt,
      this.updatedAt});

  WebinarEventModel.fromJson(Map<String, dynamic> json) {
    settingId = json['setting_id'];
    webinarTitle = json['webinar_title'];
    webinarDesc = json['webinar_desc'];
    webinarTime = json['webinar_time'];
    webinarId = json['webinar_id'];
    vimeoWebinarId = json['vimeo_webinar_id'];
    status = json['status'];
    webinarChat = json['webinar_chat'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setting_id'] = this.settingId;
    data['webinar_title'] = this.webinarTitle;
    data['webinar_desc'] = this.webinarDesc;
    data['webinar_time'] = this.webinarTime;
    data['webinar_id'] = this.webinarId;
    data['vimeo_webinar_id'] = this.vimeoWebinarId;
    data['status'] = this.status;
    data['webinar_chat'] = this.webinarChat;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
