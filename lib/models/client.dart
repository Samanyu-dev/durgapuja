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
      id: map['id'],
      name: map['name'],
      requirements: map['requirements'],
      deliveryDate: DateTime.parse(map['deliveryDate']),
      status: map['status'],
    );
  }
}

class Client {
  final String id;
  final String name;
  final String phone;
  final List<IdolOrder> idols;
  final double pendingAmount;
  final List<DateTime> deliveryDates;
  final List<String> notes;
  final String? photoUrl;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.idols,
    required this.pendingAmount,
    required this.deliveryDates,
    required this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'idols': idols.map((idol) => idol.toMap()).toList(),
      'pendingAmount': pendingAmount,
      'deliveryDates': deliveryDates.map((date) => date.toIso8601String()).toList(),
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      idols: (map['idols'] as List<dynamic>).map((idol) => IdolOrder.fromMap(idol)).toList(),
      pendingAmount: map['pendingAmount'].toDouble(),
      deliveryDates: (map['deliveryDates'] as List<dynamic>).map((date) => DateTime.parse(date)).toList(),
      notes: List<String>.from(map['notes']),
      photoUrl: map['photoUrl'],
    );
  }
}
