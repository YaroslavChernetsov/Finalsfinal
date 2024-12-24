import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sweet_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<List<Sweet>> getSweets() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('sweets').get();
      return snapshot.docs
          .map((doc) => Sweet.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching sweets: $e');
    }
  }


  Future<Sweet> getSweetById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('sweets').doc(id).get();
      return Sweet.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching sweet by ID: $e');
    }
  }


  Future<void> createSweet(Sweet sweet) async {
    try {
      await _firestore.collection('sweets').add(sweet.toJson());
    } catch (e) {
      throw Exception('Error creating sweet: $e');
    }
  }


  Future<void> updateSweet(String id, Sweet sweet) async {
    try {
      await _firestore.collection('sweets').doc(id).update(sweet.toJson());
    } catch (e) {
      throw Exception('Error updating sweet: $e');
    }
  }


  Future<void> deleteSweet(String id) async {
    try {
      await _firestore.collection('sweets').doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting sweet: $e');
    }
  }


  Stream<List<Sweet>> getSweetsStream() {
    return _firestore.collection('sweets').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Sweet.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}