import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service ulasan produk api
class ReviewService {
  final Dio _dio = DioEcommerceClient().dio;

  // fetch ulasan produk
  Future<Response> getProductReviews(String productId, {int page = 1, int limit = 10}) async {
    return await _dio.get('/reviews/product/$productId', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  // tambah ulasan baru
  Future<Response> addReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final data = <String, dynamic>{'rating': rating};
    if (comment != null && comment.isNotEmpty) data['comment'] = comment;
    return await _dio.post('/reviews/product/$productId', data: data);
  }

  // hapus ulasan sendiri
  Future<Response> deleteReview(String reviewId) async {
    return await _dio.delete('/reviews/$reviewId');
  }
}
