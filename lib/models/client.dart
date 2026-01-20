import 'idol_order.dart';

class Client {
  final String id;
  final String name;
  final String phone;
  final String status;
  final String? photoUrl;
  final List<IdolOrder> idols;
  final double pendingAmount;
  final List<DateTime> deliveryDates;
  final List<String> notes;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.photoUrl,
    this.idols = const [],
    this.pendingAmount = 0.0,
    this.deliveryDates = const [],
    this.notes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'status': status,
      'photoUrl': photoUrl,
      'idols': idols.map((idol) => idol.toMap()).toList(),
      'pendingAmount': pendingAmount,
      'deliveryDates': deliveryDates.map((date) => date.toIso8601String()).toList(),
      'notes': notes,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? '',
      photoUrl: map['photoUrl'],
      idols: (map['idols'] as List<dynamic>?)?.map((item) => IdolOrder.fromMap(item as Map<String, dynamic>)).toList() ?? [],
      pendingAmount: (map['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryDates: (map['deliveryDates'] as List<dynamic>?)?.map((item) => DateTime.parse(item as String)).toList() ?? [],
      notes: (map['notes'] as List<dynamic>?)?.map((item) => item as String).toList() ?? [],
    );
  }
}
