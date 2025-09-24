class Number {
  final int id;
  final int count;
  final DateTime createdAt;

  const Number({
    required this.id,
    required this.count,
    required this.createdAt,
  });

  factory Number.fromJson(Map<String, dynamic> json) {
    return Number(
      id: json['id'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'id: $id, count: $count, createdAt: $createdAt';
  }
}
