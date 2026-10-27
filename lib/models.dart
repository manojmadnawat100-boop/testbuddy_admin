import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id, name, sub;
  final int price;
  const Product(this.id, this.name, this.sub, this.price);

  factory Product.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Product(d.id, '${m['name'] ?? ''}', '${m['sub'] ?? ''}',
        (m['price'] as num?)?.toInt() ?? 0);
  }
}
