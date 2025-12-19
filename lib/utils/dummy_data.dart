import '../models/client.dart';
import '../models/transaction.dart';

class DummyData {
  static List<Client> clients = [
    Client(
      id: '1',
      name: 'Rohan Sharma',
      phone: '+91 98765 43210',
      idols: [
        IdolOrder(
          id: '1',
          name: 'Ganesh Idol',
          requirements: 'Traditional design with gold accents',
          deliveryDate: DateTime(2024, 10, 15),
          status: 'In Progress',
        ),
        IdolOrder(
          id: '2',
          name: 'Durga Idol',
          requirements: 'Large scale, intricate detailing',
          deliveryDate: DateTime(2024, 11, 1),
          status: 'Pending',
        ),
      ],
      pendingAmount: 15000,
      deliveryDates: [
        DateTime(2024, 10, 15),
        DateTime(2024, 11, 1),
      ],
      notes: [
        'Excited about the Ganesh idol progress',
        'Requested larger Durga idol',
      ],
    ),
    Client(
      id: '2',
      name: 'Priya Patel',
      phone: '+91 87654 32109',
      idols: [
        IdolOrder(
          id: '3',
          name: 'Lakshmi Idol',
          requirements: 'Elegant and serene expression',
          deliveryDate: DateTime(2024, 10, 20),
          status: 'Completed',
        ),
      ],
      pendingAmount: 0,
      deliveryDates: [
        DateTime(2024, 10, 20),
      ],
      notes: [
        'Very satisfied with the Lakshmi idol',
      ],
    ),
    Client(
      id: '3',
      name: 'Amit Kumar',
      phone: '+91 76543 21098',
      idols: [
        IdolOrder(
          id: '4',
          name: 'Saraswati Idol',
          requirements: 'Musical instruments as decoration',
          deliveryDate: DateTime(2024, 10, 25),
          status: '2 day delay',
        ),
      ],
      pendingAmount: 8000,
      deliveryDates: [
        DateTime(2024, 10, 25),
      ],
      notes: [
        'Requested changes to the veena design',
      ],
    ),
  ];

  static List<MaterialRate> materials = [
    MaterialRate(
      id: '1',
      materialName: 'Clay',
      unit: 'kg',
      rate: 150,
      lastUpdated: DateTime(2024, 9, 1),
    ),
    MaterialRate(
      id: '2',
      materialName: 'Paint',
      unit: 'liter',
      rate: 500,
      lastUpdated: DateTime(2024, 9, 5),
    ),
    MaterialRate(
      id: '3',
      materialName: 'Bamboo',
      unit: 'piece',
      rate: 200,
      lastUpdated: DateTime(2024, 9, 10),
    ),
  ];

  static List<Transaction> transactions = [
    Transaction(
      id: '1',
      title: 'Ganesh Idol Payment',
      date: DateTime(2024, 9, 15),
      amount: 25000,
      category: 'Income',
    ),
    Transaction(
      id: '2',
      title: 'Clay Purchase',
      date: DateTime(2024, 9, 10),
      amount: -5000,
      category: 'Expense',
    ),
    Transaction(
      id: '3',
      title: 'Paint Materials',
      date: DateTime(2024, 9, 12),
      amount: -3000,
      category: 'Expense',
    ),
  ];

  static Client? getClientById(String id) {
    return clients.firstWhere((client) => client.id == id);
  }

  static String getClientNameById(String id) {
    final client = getClientById(id);
    return client?.name ?? 'Unknown Client';
  }
}
