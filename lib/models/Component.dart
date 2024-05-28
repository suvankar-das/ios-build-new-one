class Component {
  final String compType;
  final String arrangement;
  final String limit;
  final String id;

  Component({
    required this.compType,
    required this.arrangement,
    required this.limit,
    required this.id,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      compType: json['comp_type'] as String,
      arrangement: json['arrangement'] as String,
      limit: json['limit'] as String,
      id: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comp_type': compType,
      'arrangement': arrangement,
      'limit': limit,
      '_id': id,
    };
  }
}
