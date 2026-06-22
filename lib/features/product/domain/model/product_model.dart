import 'package:mini_erp/features/product/domain/model/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.category,
    required super.price,
    required super.stock,
    required super.description,
    required super.updatedat,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      sku: product.sku,
      category: product.category,
      price: product.price,
      stock: product.stock,
      description: product.description,
      updatedat: product.updatedat,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      description: json['description'],
      updatedat: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'updatedAt': updatedat.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stock,
    String? description,
    DateTime? updatedat,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      updatedat: updatedat ?? this.updatedat,
    );
  }
}
