class Movie {
  String? id;
  String? type;
  String? title;
  List<String>? category;
  List<String>? tags;
  String? status;
  Media? media;
  int? createdAt;
  int? updatedAt;
  int? version;
  String? description;
  bool? doNotShowAd;
  String? rating;
  String? updatedBy;
  Images? images;
  String? permalink;
  Casting? casting;

  Movie({
    this.id,
    this.type,
    this.title,
    this.category,
    this.tags,
    this.status,
    this.media,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.description,
    this.doNotShowAd,
    this.rating,
    this.updatedBy,
    this.images,
    this.permalink,
    this.casting,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      category: (json['category'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      description: json['desc'] as String?,
      doNotShowAd: json['do_not_show_ad'] as bool?,
      rating: json['rating'] as String?,
      updatedBy: json['updated_by'] as String?,
      images: json['images'] != null ? Images.fromJson(json['images']) : null,
      permalink: json['permalink'] as String?,
      casting:
          json['casting'] != null ? Casting.fromJson(json['casting']) : null,
    );
  }
}

class Media {
  String? hlsFileId;
  String? encodedFilePath;

  Media({
    this.hlsFileId,
    this.encodedFilePath,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      hlsFileId: json['hls_file_id'] as String,
      encodedFilePath: json['encoded_file_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hls_file_id': hlsFileId,
      'encoded_file_path': encodedFilePath,
    };
  }
}

class Images {
  String? img32_9;
  String? img16_9;
  String? img9_16;
  String? img1_1;
  String? img4_3;

  Images({
    this.img32_9,
    this.img16_9,
    this.img9_16,
    this.img1_1,
    this.img4_3,
  });

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      img32_9: json['img_32_9'] as String?,
      img16_9: json['img_16_9'] as String?,
      img9_16: json['img_9_16'] as String?,
      img1_1: json['img_1_1'] as String?,
      img4_3: json['img_4_3'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'img_32_9': img32_9,
      'img_16_9': img16_9,
      'img_9_16': img9_16,
      'img_1_1': img1_1,
      'img_4_3': img4_3,
    };
  }
}

class Casting {
  List<String>? director;
  List<String>? cast;

  Casting({
    required this.director,
    required this.cast,
  });

  factory Casting.fromJson(Map<String, dynamic> json) {
    return Casting(
      director: List<String>.from(json['director']),
      cast: List<String>.from(json['cast']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'director': director,
      'cast': cast,
    };
  }
}
