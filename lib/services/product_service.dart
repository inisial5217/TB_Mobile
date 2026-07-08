import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service produk dan kategori api
class ProductService {
  final Dio _dio = DioEcommerceClient().dio;

  // fetch data products dengan filter/sort/pagination
  Future<Response> getProducts({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) {
      params['category_id'] = categoryId;
    }
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;

    return await _dio.get('/products', queryParameters: params);
  }

  // fetch detail produk by id
  Future<Response> getProductDetail(String productId) async {
    return await _dio.get('/products/$productId');
  }

  // fetch semua kategori
  Future<Response> getCategories() async {
    return await _dio.get('/categories');
  }
}
