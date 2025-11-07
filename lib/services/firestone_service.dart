// Firebase services

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await _itemsRef.add(item.toMap());
  }

  Stream<List<Item>> getItemsStream() {
    return _itemsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
//firestone functions
  Future<void> updateItem(Item item) async {
    if (item.id == null) return;
    await _itemsRef.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _itemsRef.doc(itemId).delete();
  }
  Future<void> deleteMultipleItems(List<String> ids) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in ids) {
      final docRef = _itemsRef.doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }
}
