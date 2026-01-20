class IdolOrder {
  final String id;
  final String name;
  final String requirements;
  final DateTime deliveryDate;
  final String status;

  IdolOrder({
    required this.id,
    required this.name,
    required this.requirements,
    required this.deliveryDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'requirements': requirements,
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status,
    };
  }

  factory IdolOrder.fromMap(Map<String, dynamic> map) {
    return IdolOrder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      requirements: map['requirements'] ?? '',
      deliveryDate: DateTime.parse(map['deliveryDate']),
      status: map['status'] ?? '',
    );
  }
}
