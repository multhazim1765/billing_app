import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class ProductModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String barcode;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
  });

  static String _normalizeBarcode(String value) => value.trim().toLowerCase();

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: _normalizeBarcode(product.barcode),
      price: product.price,
      stock: product.stock,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: _normalizeBarcode(barcode),
      price: price,
      stock: stock,
    );
  }
}
