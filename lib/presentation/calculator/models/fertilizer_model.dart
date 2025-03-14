import 'dart:convert';

class FertilizerModel {
  final String image;
  final String name;
  final String category;
  final int price;
  final double weight;
  final String type;
  final Map<String, dynamic> macro;
  final Map<String, dynamic> micro;

  FertilizerModel({
    required this.image,
    required this.name,
    required this.category,
    required this.price,
    required this.weight,
    required this.type,
    required this.macro,
    required this.micro,
  });

  // Method untuk mengonversi ke format Map (untuk serialisasi, misalnya ke JSON)
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'category': category,
      'price': price,
      'weight': weight,
      'type': type,
      'macro': jsonEncode(macro),
      'micro': jsonEncode(micro),
    };
  }

  // Method untuk mengonversi dari format Map (untuk deserialisasi, misalnya dari JSON)
  factory FertilizerModel.fromMap(Map<String, dynamic> map) {
    return FertilizerModel(
      image: map['image'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      weight: map['weight'],
      type: map['type'],
      macro: Map<String, dynamic>.from(jsonDecode(map['macro'])),
      micro: Map<String, dynamic>.from(jsonDecode(map['micro'])),
    );
  }

  // Menambahkan toString untuk memudahkan pencetakan objek FertilizerModel
  @override
  String toString() {
    return 'FertilizerModel(name: $name, category: $category, price: $price, weight: $weight,  type: $type, macro: $macro, micro: $micro)';
  }

  Map<String, dynamic> toMapRequest() {
    return {
      'name': name,
      'type': type,
      'nutrient_content': {
        ...macro,
        ...micro,
      },
    };
  }
}
