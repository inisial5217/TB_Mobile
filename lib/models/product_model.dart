import 'package:tb_ecommerce/models/category_model.dart';

// model produk e-commerce
class ProductModel {
  final String id; // param produk id
  final String name; // param nama produk
  final String? slug; // param slug url
  final String description; // param deskripsi
  final num price; // param harga
  final int stock; // param stok
  final String? categoryId; // param id kategori
  final String? imageUrl; // param url gambar
  final bool isActive; // param status aktif
  final CategoryModel? category; // param objek kategori
  final double averageRating; // param rata-rata rating
  final int totalReviews; // param jumlah ulasan
  final String? createdAt; // param tanggal dibuat

  // constructor init
  ProductModel({
    required this.id,
    required this.name,
    this.slug,
    required this.description,
    required this.price,
    required this.stock,
    this.categoryId,
    this.imageUrl,
    this.isActive = true,
    this.category,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.createdAt,
  });

  // parse json produk
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      slug: json['slug'],
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: json['category_id'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'])
          : null,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      createdAt: json['created_at'],
    );
  }

  // konversi ke json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
    };
  }
}
