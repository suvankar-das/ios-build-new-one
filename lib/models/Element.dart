class Element {
  final String orientation;
  final String size;
  final bool isHover;
  final bool isFooterTitle;
  final String id;

  Element({
    required this.orientation,
    required this.size,
    required this.isHover,
    required this.isFooterTitle,
    required this.id,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      orientation: json['orientation'] as String,
      size: json['size'] as String,
      isHover: json['is_hover'] as bool,
      isFooterTitle: json['is_footer_title'] as bool,
      id: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orientation': orientation,
      'size': size,
      'is_hover': isHover,
      'is_footer_title': isFooterTitle,
      '_id': id,
    };
  }
}
