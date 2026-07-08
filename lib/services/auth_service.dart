import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service autentikasi api
class AuthService {
  final Dio _dio = DioEcommerceClient().dio;

  // register akun baru
  Future<Response> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
    });
  }

  // login user
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  // fetch data profil user
  Future<Response> getProfile() async {
    return await _dio.get('/auth/profile');
  }

  // update profil user
  Future<Response> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    return await _dio.put('/auth/profile', data: data);
  }

  // logout user
  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }
}
