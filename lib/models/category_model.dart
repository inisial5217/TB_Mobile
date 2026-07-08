// model kategori produk
class CategoryModel {
  final String id; // param kategori id
  final String name; // param nama kategori
  final String? slug; // param slug url
  final String? description; // param deskripsi
  final String? imageUrl; // param url gambar

  // constructor init
  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.imageUrl,
  });

  // parse json kategori
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Uncategorized',
      slug: json['slug'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
