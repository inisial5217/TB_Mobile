// model item keranjang belanja
class CartItemModel {
  final String id; // param cart item id
  final String productId; // param produk id
  final String productName; // param nama produk
  final String? productImage; // param gambar produk
  final num price; // param harga satuan
  final int quantity; // param jumlah
  final num subtotal; // kalkulasi subtotal

  // constructor init
  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  // parse json cart item
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] ?? json['product'] ?? {};
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? product['id'] ?? '',
      productName: product['name'] ?? json['product_name'] ?? 'No Name',
      productImage: product['image_url'] ?? json['product_image'],
      price: product['price'] ?? json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      subtotal: json['subtotal'] ?? (json['quantity'] ?? 1) * (product['price'] ?? json['price'] ?? 0),
    );
  }
}

// model keranjang utama
class CartModel {
  final String? cartId; // param cart id
  final List<CartItemModel> items; // daftar item
  final int totalItems; // total jumlah item
  final num totalPrice; // total harga keseluruhan

  // constructor init
  CartModel({
    this.cartId,
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  // parse json keranjang
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List? ?? [];
    final parsedItems =
        itemsRaw.map((e) => CartItemModel.fromJson(e)).toList();
    return CartModel(
      cartId: json['cart_id'],
      items: parsedItems,
      totalItems: json['total_items'] ?? parsedItems.length,
      totalPrice: json['total_price'] ?? 0,
    );
  }
}
