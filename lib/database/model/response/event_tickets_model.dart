class EventTickets {
  String? id;
  String? eventName;
  String? eventBanner;
  List<TicketType>? ticketType;
  String? status;
  String? createdAt;
  String? updatedAt;

  EventTickets(
      {this.id,
      this.eventName,
      this.eventBanner,
      this.ticketType,
      this.status,
      this.createdAt,
      this.updatedAt});

  EventTickets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    eventName = json['event_name'];
    eventBanner = json['event_banner'];
    try {
      if (json['ticket_type'] != null) {
        ticketType = <TicketType>[];
        json['ticket_type'].forEach((v) {
          ticketType!.add(new TicketType.fromJson(v));
        });
      }
    } catch (e) {
      print('event tickets from json error $e');
    }
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['event_name'] = this.eventName;
    data['event_banner'] = this.eventBanner;
    if (this.ticketType != null) {
      data['ticket_type'] = this.ticketType!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class TicketType {
  int? member;
  String? amount;
  String? text;

  TicketType({this.member, this.amount, this.text});

  TicketType.fromJson(Map<String, dynamic> json) {
    member = json['member'];
    amount = json['amount'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member'] = this.member;
    data['amount'] = this.amount;
    data['text'] = this.text;
    return data;
  }
}
