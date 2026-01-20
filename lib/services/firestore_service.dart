import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/client.dart';
import '../models/transaction.dart' as models; // Avoid naming conflict with Firestore Transaction

class FirestoreService {
  final firestore.FirebaseFirestore _firestore = 
      firestore.FirebaseFirestore.instance;

  // Collection references
  firestore.CollectionReference get _clientsCollection => 
      _firestore.collection('clients');
  
  firestore.CollectionReference get _transactionsCollection => 
      _firestore.collection('transactions');
  
  firestore.CollectionReference get _materialsCollection => 
      _firestore.collection('materials');

  // ==================== CLIENT OPERATIONS ====================
  
  Future<void> addClient(Client client) async {
    try {
      await _clientsCollection.doc(client.id).set(client.toMap());
    } catch (e) {
      print('Error adding client: $e');
      rethrow;
    }
  }

  Future<List<Client>> getClients() async {
    try {
      final querySnapshot = await _clientsCollection.get();
      return querySnapshot.docs
          .map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting clients: $e');
      return [];
    }
  }

  Future<Client?> getClientById(String id) async {
    try {
      final docSnapshot = await _clientsCollection.doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return Client.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting client by ID: $e');
      return null;
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      await _clientsCollection.doc(client.id).update(client.toMap());
    } catch (e) {
      print('Error updating client: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _clientsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting client: $e');
      rethrow;
    }
  }

  // Get clients with pagination
  Future<List<Client>> getClientsPaginated({
    int limit = 20,
    firestore.DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _clientsCollection.limit(limit);
      
      if (startAfter != null) {
        // ignore: unnecessary_cast
        query = query.startAfterDocument(startAfter) as firestore.Query;
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting paginated clients: $e');
      return [];
    }
  }

  // Search clients by name or phone
  Future<List<Client>> searchClients(String searchTerm) async {
    try {
      final querySnapshot = await _clientsCollection
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================
  
  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<List<models.Transaction>> getTransactions() async {
    try {
      final querySnapshot = await _transactionsCollection
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => models.Transaction.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<models.Transaction?> getTransactionById(String id) async {
    try {
      final docSnapshot = await _transactionsCollection.doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return models.Transaction.fromMap(
            docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting transaction by ID: $e');
      return null;
    }
  }

  Future<void> updateTransaction(models.Transaction transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get transactions for a specific client
  Future<List<models.Transaction>> getTransactionsByClient(
      String clientId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('clientId', isEqualTo: clientId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => models.Transaction.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting transactions by client: $e');
      return [];
    }
  }

  // Get transactions within a date range
  Future<List<models.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => models.Transaction.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting transactions by date range: $e');
      return [];
    }
  }

  // ==================== MATERIAL OPERATIONS ====================

  Future<void> addMaterial(models.MaterialRate material) async {
    try {
      await _materialsCollection.doc(material.id).set(material.toMap());
    } catch (e) {
      print('Error adding material: $e');
      rethrow;
    }
  }

  Future<List<models.MaterialRate>> getMaterials() async {
    try {
      final querySnapshot = await _materialsCollection
          .orderBy('materialName')
          .get();

      return querySnapshot.docs
          .map((doc) => models.MaterialRate.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting materials: $e');
      return [];
    }
  }

  Future<models.MaterialRate?> getMaterialById(String id) async {
    try {
      final docSnapshot = await _materialsCollection.doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return models.MaterialRate.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting material by ID: $e');
      return null;
    }
  }

  Future<void> updateMaterial(models.MaterialRate material) async {
    try {
      await _materialsCollection.doc(material.id).update(material.toMap());
    } catch (e) {
      print('Error updating material: $e');
      rethrow;
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _materialsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting material: $e');
      rethrow;
    }
  }

  // Get active materials only
  Future<List<models.MaterialRate>> getActiveMaterials() async {
    try {
      final querySnapshot = await _materialsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('materialName')
          .get();

      return querySnapshot.docs
          .map((doc) => models.MaterialRate.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting active materials: $e');
      return [];
    }
  }

  // ==================== UTILITY METHODS ====================

  // Listen to real-time client updates
  Stream<List<Client>> clientsStream() {
    return _clientsCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  // Listen to real-time transaction updates
  Stream<List<models.Transaction>> transactionsStream() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => models.Transaction.fromMap(
                  doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Listen to real-time material updates
  Stream<List<models.MaterialRate>> materialsStream() {
    return _materialsCollection.orderBy('materialName').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  models.MaterialRate.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Batch operations
  Future<void> addMultipleClients(List<Client> clients) async {
    final batch = _firestore.batch();
    
    for (var client in clients) {
      final docRef = _clientsCollection.doc(client.id);
      batch.set(docRef, client.toMap());
    }
    
    await batch.commit();
  }

  Future<void> deleteMultipleTransactions(List<String> transactionIds) async {
    final batch = _firestore.batch();
    
    for (var id in transactionIds) {
      final docRef = _transactionsCollection.doc(id);
      batch.delete(docRef);
    }
    
    await batch.commit();
  }
}
