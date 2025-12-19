import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/client.dart';
import '../models/transaction.dart';

class FirestoreService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  // Clients Collection
  firestore.CollectionReference get _clientsCollection => _firestore.collection('clients');
  firestore.CollectionReference get _transactionsCollection => _firestore.collection('transactions');
  firestore.CollectionReference get _materialsCollection => _firestore.collection('materials');

  // CRUD operations for Clients
  Future<void> addClient(Client client) async {
    await _clientsCollection.doc(client.id).set(client.toMap());
  }

  Future<List<Client>> getClients() async {
    final querySnapshot = await _clientsCollection.get();
    return querySnapshot.docs.map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<Client?> getClientById(String id) async {
    final docSnapshot = await _clientsCollection.doc(id).get();
    if (docSnapshot.exists) {
      return Client.fromMap(docSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateClient(Client client) async {
    await _clientsCollection.doc(client.id).update(client.toMap());
  }

  Future<void> deleteClient(String id) async {
    await _clientsCollection.doc(id).delete();
  }

  // CRUD operations for Transactions
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsCollection.doc(transaction.id).set(transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    final querySnapshot = await _transactionsCollection.get();
    return querySnapshot.docs.map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // CRUD operations for Materials
  Future<void> addMaterial(MaterialRate material) async {
    await _materialsCollection.doc(material.id).set(material.toMap());
  }

  Future<List<MaterialRate>> getMaterials() async {
    final querySnapshot = await _materialsCollection.get();
    return querySnapshot.docs.map((doc) => MaterialRate.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> updateMaterial(MaterialRate material) async {
    await _materialsCollection.doc(material.id).update(material.toMap());
  }
}
