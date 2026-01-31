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
    try {
      return IdolOrder(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        requirements: map['requirements'] ?? '',
        deliveryDate: DateTime.parse(map['deliveryDate']),
        status: map['status'] ?? '',
      );
    } catch (e) {
      // Return a default order if parsing fails
      return IdolOrder(
        id: map['id'] ?? '',
        name: map['name'] ?? 'Unknown Idol',
        requirements: map['requirements'] ?? '',
        deliveryDate: DateTime.now().add(const Duration(days: 7)),
        status: map['status'] ?? 'pending',
      );
    }
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           deliveryDate.isAfter(DateTime.now().subtract(const Duration(days: 365)));
  }

  // Helper methods
  bool isOverdue() => deliveryDate.isBefore(DateTime.now()) && status != 'completed';
  bool isDueSoon() => deliveryDate.isBefore(DateTime.now().add(const Duration(days: 3))) && status != 'completed';
  bool isCompleted() => status.toLowerCase() == 'completed';
  
  String getStatusDisplay() {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New Order';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }
}
