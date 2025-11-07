// item layout
import 'package:cloud_firestore/cloud_firestore.dart';
//fields
class Item {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime createdAt;
//requirements
  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
//hash layout
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0) as double,
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
