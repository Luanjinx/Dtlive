import 'dart:convert';

LiveTvModel liveTvModelFromJson(String str) =>
    LiveTvModel.fromJson(json.decode(str));

String liveTvModelToJson(LiveTvModel data) => json.encode(data.toJson());

class LiveTvModel {
  int? status;
  String? message;
  List<Result>? result;

  LiveTvModel({
    this.status,
    this.message,
    this.result,
  });

  factory LiveTvModel.fromJson(Map<String, dynamic> json) => LiveTvModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class Result {
  int? id;
  int? categoryId;
  String? name;
  dynamic description;
  String? streamUrl;
  String? portraitThumbnail;
  String? landscapeThumbnail;
  int? isPremium;
  int? status;
  int? viewCount;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.streamUrl,
    this.portraitThumbnail,
    this.landscapeThumbnail,
    this.isPremium,
    this.status,
    this.viewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        categoryId: json["category_id"],
        name: json["name"],
        description: json["description"],
        streamUrl: json["stream_url"],
        portraitThumbnail: json["portrait_thumbnail"],
        landscapeThumbnail: json["landscape_thumbnail"],
        isPremium: json["is_premium"],
        status: json["status"],
        viewCount: json["view_count"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "name": name,
        "description": description,
        "stream_url": streamUrl,
        "portrait_thumbnail": portraitThumbnail,
        "landscape_thumbnail": landscapeThumbnail,
        "is_premium": isPremium,
        "status": status,
        "view_count": viewCount,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
