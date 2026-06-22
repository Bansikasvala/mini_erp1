import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/model/order_item.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerName,
    required super.items,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      items: order.items,
      status: order.status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      customerName: json['customerName'],
      items: itemsJson
          .map((item) => OrderItem(
                productId: item['productId'],
                productName: item['productName'],
                sku: item['sku'],
                quantity: item['quantity'],
                unitPrice: (item['unitPrice'] as num).toDouble(),
              ))
          .toList(),
      status: OrderStatus.fromValue(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'items': items
          .map(
            (item) => {
              'productId': item.productId,
              'productName': item.productName,
              'sku': item.sku,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
            },
          )
          .toList(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
