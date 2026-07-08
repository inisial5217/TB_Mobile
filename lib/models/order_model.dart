// model pesanan e-commerce
class OrderModel {
  final String id; // param order id (uuid)
  final String? userId; // param user id
  final String status; // param status pesanan
  final String? shippingAddress; // param alamat pengiriman
  final String? notes; // param catatan
  final num totalAmount; // param total harga
  final List<OrderItemModel> items; // daftar item pesanan
  final String? createdAt; // param tanggal dibuat
  final OrderProfileModel? profile; // param info pemesan (admin view)

  // constructor init
  OrderModel({
    required this.id,
    this.userId,
    required this.status,
    this.shippingAddress,
    this.notes,
    required this.totalAmount,
    required this.items,
    this.createdAt,
    this.profile,
  });

  // parse json pesanan
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['order_items'] ?? json['items'] ?? [];
    final parsedItems = (itemsRaw as List)
        .map((e) => OrderItemModel.fromJson(e))
        .toList();
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'],
      notes: json['notes'],
      totalAmount: json['total_amount'] ?? 0,
      items: parsedItems,
      createdAt: json['created_at'],
      profile: json['profiles'] != null
          ? OrderProfileModel.fromJson(json['profiles'])
          : null,
    );
  }

  // 8 karakter pertama uuid sebagai nomor pesanan
  String get shortOrderId => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}

// model item dalam pesanan
class OrderItemModel {
  final String? id;
  final String? productId;
  final String productName;
  final String? productImage;
  final num price;
  final int quantity;
  final num subtotal;

  OrderItemModel({
    this.id,
    this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  // parse json order item
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] ?? json['product'] ?? {};
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'] ?? product['id'],
      productName: product['name'] ?? json['product_name'] ?? 'Produk',
      productImage: product['image_url'] ?? json['product_image'],
      price: json['price_at_time'] ?? json['price'] ?? product['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      subtotal: json['subtotal'] ?? ((json['quantity'] ?? 1) * (json['price_at_time'] ?? json['price'] ?? 0)),
    );
  }
}

// model profil singkat pemesan (admin view)
class OrderProfileModel {
  final String? fullName;
  final String? email;

  OrderProfileModel({this.fullName, this.email});

  factory OrderProfileModel.fromJson(Map<String, dynamic> json) {
    return OrderProfileModel(
      fullName: json['full_name'],
      email: json['email'],
    );
  }
}
