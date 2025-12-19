// Firebase Firestore service - commented out for development without Firebase
// import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/client.dart';
import '../models/transaction.dart';

class FirestoreService {
  // Firebase commented out for development
  // final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  // Collections commented out
  // firestore.CollectionReference get _clientsCollection => _firestore.collection('clients');
  // firestore.CollectionReference get _transactionsCollection => _firestore.collection('transactions');
  // firestore.CollectionReference get _materialsCollection => _firestore.collection('materials');

  // CRUD operations for Clients - stub implementations for development
  Future<void> addClient(Client client) async {
    // TODO: Implement Firebase Firestore integration
    // await _clientsCollection.doc(client.id).set(client.toMap());
    print('Firestore not available - addClient stub');
  }

  Future<List<Client>> getClients() async {
    // TODO: Implement Firebase Firestore integration
    // final querySnapshot = await _clientsCollection.get();
    // return querySnapshot.docs.map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>)).toList();
    print('Firestore not available - getClients stub');
    return []; // Return empty list for development
  }

  Future<Client?> getClientById(String id) async {
    // TODO: Implement Firebase Firestore integration
    // final docSnapshot = await _clientsCollection.doc(id).get();
    // if (docSnapshot.exists) {
    //   return Client.fromMap(docSnapshot.data() as Map<String, dynamic>);
    // }
    // return null;
    print('Firestore not available - getClientById stub');
    return null; // Return null for development
  }

  Future<void> updateClient(Client client) async {
    // TODO: Implement Firebase Firestore integration
    // await _clientsCollection.doc(client.id).update(client.toMap());
    print('Firestore not available - updateClient stub');
  }

  Future<void> deleteClient(String id) async {
    // TODO: Implement Firebase Firestore integration
    // await _clientsCollection.doc(id).delete();
    print('Firestore not available - deleteClient stub');
  }

  // CRUD operations for Transactions - stub implementations
  Future<void> addTransaction(Transaction transaction) async {
    // TODO: Implement Firebase Firestore integration
    // await _transactionsCollection.doc(transaction.id).set(transaction.toMap());
    print('Firestore not available - addTransaction stub');
  }

  Future<List<Transaction>> getTransactions() async {
    // TODO: Implement Firebase Firestore integration
    // final querySnapshot = await _transactionsCollection.get();
    // return querySnapshot.docs.map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>)).toList();
    print('Firestore not available - getTransactions stub');
    return []; // Return empty list for development
  }

  // CRUD operations for Materials - stub implementations
  Future<void> addMaterial(MaterialRate material) async {
    // TODO: Implement Firebase Firestore integration
    // await _materialsCollection.doc(material.id).set(material.toMap());
    print('Firestore not available - addMaterial stub');
  }

  Future<List<MaterialRate>> getMaterials() async {
    // TODO: Implement Firebase Firestore integration
    // final querySnapshot = await _materialsCollection.get();
    // return querySnapshot.docs.map((doc) => MaterialRate.fromMap(doc.data() as Map<String, dynamic>)).toList();
    print('Firestore not available - getMaterials stub');
    return []; // Return empty list for development
  }

  Future<void> updateMaterial(MaterialRate material) async {
    // TODO: Implement Firebase Firestore integration
    // await _materialsCollection.doc(material.id).update(material.toMap());
    print('Firestore not available - updateMaterial stub');
  }
}
