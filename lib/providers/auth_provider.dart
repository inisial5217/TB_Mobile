import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_ecommerce/core/constants.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/models/user_model.dart';
import 'package:tb_ecommerce/services/auth_service.dart';

// provider state management autentikasi
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser; // user yang sedang login
  bool _isLoading = false; // status loading
  String? _errorMessage; // pesan error
  bool _isLoggedIn = false; // status login

  // getter
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // cek auto-login dari token tersimpan
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(Constants.tokenStorageKey);
    if (storedToken == null || storedToken.isEmpty) return false;

    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['data']);
        _isLoggedIn = true;
        // simpan role untuk pengecekan cepat
        await prefs.setString(
          Constants.userRoleKey,
          _currentUser?.role?.name ?? 'customer',
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      // token invalid, hapus
      await prefs.remove(Constants.tokenStorageKey);
      await prefs.remove(Constants.userRoleKey);
    }
    return false;
  }

  // register akun baru
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _setLoading(false);
      return response.statusCode == 201 || response.data['success'] == true;
    } on DioException catch (e) {
      _setError(DioEcommerceClient.parseErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        // secure token save
        final token = response.data['data']['access_token'] ??
            response.data['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenStorageKey, token);

        // fetch profil setelah login
        await fetchProfile();
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      }
      _setError('Login gagal. Periksa email dan password Anda.');
      _setLoading(false);
      return false;
    } on DioException catch (e) {
      _setError(DioEcommerceClient.parseErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // fetch data profil
  Future<void> fetchProfile() async {
    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['data']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          Constants.userRoleKey,
          _currentUser?.role?.name ?? 'customer',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal fetch profil: $e');
    }
  }

  // update profil
  Future<bool> updateProfile({String? fullName, String? phone}) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchProfile();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } on DioException catch (e) {
      _setError(DioEcommerceClient.parseErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // logout user - clear all storage
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // tetap lanjut logout meskipun api gagal
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenStorageKey);
    await prefs.remove(Constants.userRoleKey);
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
