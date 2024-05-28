import 'package:ott_code_frontend/models/Component.dart';
import 'package:ott_code_frontend/models/Element.dart';
import 'package:ott_code_frontend/models/Movie.dart';

class Settings {
  String? id;
  String? pageId;
  int? version;
  Component? component;
  List<String>? content;
  Element? element;
  bool? hideAfterLogin;
  bool? isActive;
  bool? isDelete;
  String? title;
  List<Movie>? movies;

  Settings({
    this.id,
    this.pageId,
    this.version,
    this.component,
    this.content,
    this.element,
    this.hideAfterLogin,
    this.isActive,
    this.isDelete,
    this.title,
    this.movies,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'] as String?,
      pageId: json['page_id'] as String?,
      version: json['__v'] as int?,
      component: Component.fromJson(json['component']),
      content: List<String>.from(json['content']),
      element: Element.fromJson(json['element']),
      hideAfterLogin: json['hide_after_login'] as bool?,
      isActive: json['is_active'] as bool?,
      isDelete: json['is_delete'] as bool?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_id': pageId,
      '__v': version,
      'component': component!.toJson(),
      'content': content,
      'element': element!.toJson(),
      'hide_after_login': hideAfterLogin,
      'is_active': isActive,
      'is_delete': isDelete,
      'title': title,
    };
  }
}
