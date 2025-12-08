class OnboardModel {
  String? message;
  List<Data>? data;
  int? status;

  OnboardModel({this.message, this.data, this.status});

  OnboardModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Data {
  String? sId;
  String? title;
  String? description;
  String? imageUrl;
  int? pageId;
  int? iV;

  Data(
      {this.sId,
        this.title,
        this.description,
        this.imageUrl,
        this.pageId,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    pageId = json['pageId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['imageUrl'] = imageUrl;
    data['pageId'] = pageId;
    data['__v'] = iV;
    return data;
  }
}
