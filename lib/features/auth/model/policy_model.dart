class PolicyModel {
  bool? success;
  int? status;
  Data? data;

  PolicyModel({this.success, this.status, this.data});

  PolicyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? key;
  String? title;
  String? html;
  String? createdBy;
  String? updatedBy;
  int? version;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
        this.key,
        this.title,
        this.html,
        this.createdBy,
        this.updatedBy,
        this.version,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    key = json['key'];
    title = json['title'];
    html = json['html'];
    createdBy = json['createdBy'];
    updatedBy = json['updatedBy'];
    version = json['version'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['key'] = key;
    data['title'] = title;
    data['html'] = html;
    data['createdBy'] = createdBy;
    data['updatedBy'] = updatedBy;
    data['version'] = version;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
