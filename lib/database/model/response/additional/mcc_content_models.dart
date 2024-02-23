import '/database/functions.dart';

class Content {
  Cancellation? cancellation;
  Cancellation? privacy;
  Cancellation? termCondition;
  Cancellation? returnPolicy;

  Content(
      {this.cancellation, this.privacy, this.termCondition, this.returnPolicy});

  Content.fromJson(Map<String, dynamic> json) {
    cancellation = json['cancellation'] != null
        ? Cancellation.fromJson(json['cancellation'])
        : null;
    privacy =
        json['privacy'] != null ? Cancellation.fromJson(json['privacy']) : null;
    termCondition = json['term_condition'] != null
        ? Cancellation.fromJson(json['term_condition'])
        : null;
    if (json['return'] != null) {
      returnPolicy = Cancellation.fromJson(json['return']);
    } else {
      returnPolicy = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cancellation != null) {
      data['cancellation'] = cancellation!.toJson();
    }
    if (privacy != null) {
      data['privacy'] = privacy!.toJson();
    }
    if (termCondition != null) {
      data['term_condition'] = termCondition!.toJson();
    }
    if (returnPolicy != null) {
      data['return'] = returnPolicy!.toJson();
    }
    return data;
  }
}
// {
//   'cancellation':{},
//   'privacy':{},
//   'term_condition':{},
//   'return':{}
// }

class Cancellation {
  String? linkPageId;
  String? pageId;
  String? languageId;
  String? headlines;
  String? image;
  String? details;
  String? status;

  Cancellation(
      {this.linkPageId,
      this.pageId,
      this.languageId,
      this.headlines,
      this.image,
      this.details,
      this.status});

  Cancellation.fromJson(Map<String, dynamic> json) {
    linkPageId = json['link_page_id'];
    pageId = json['page_id'];
    languageId = json['language_id'];
    headlines = parseHtmlString(json['headlines'] ?? '');
    image = json['image'];
    details = json['details'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['link_page_id'] = linkPageId;
    data['page_id'] = pageId;
    data['language_id'] = languageId;
    data['headlines'] = headlines;
    data['image'] = image;
    data['details'] = details;
    data['status'] = status;
    return data;
  }
}
