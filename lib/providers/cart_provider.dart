import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/models/cart_model.dart';
import 'package:tb_ecommerce/services/cart_service.dart';

// provider state management keranjang belanja
class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart; // data keranjang
  bool _isLoading = false; // status loading
  bool _isActionLoading = false; // status loading aksi (add/update/delete)
  String? _errorMessage; // pesan error

  // getter
  CartModel? get cart => _cart;
  List<CartItemModel> get items => _cart?.items ?? [];
  int get itemCount => _cart?.totalItems ?? 0;
  num get totalPrice => _cart?.totalPrice ?? 0;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => items.isEmpty;

  // fetch data keranjang
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _cartService.getCart();
      if (response.statusCode == 200 && response.data['success'] == true) {
        _cart = CartModel.fromJson(response.data['data']);
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang.';
    }
    _isLoading = false;
    notifyListeners();
  }

  // tambah item ke keranjang
  Future<bool> addToCart(String productId, {int quantity = 1}) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final response = await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(); // refresh data keranjang
        _isActionLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isActionLoading = false;
    notifyListeners();
    return false;
  }

  // update quantity item
  Future<bool> updateItemQuantity(String cartItemId, int newQty) async {
    if (newQty < 1) return false;
    _isActionLoading = true;
    notifyListeners();

    try {
      final response = await _cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: newQty,
      );
      if (response.statusCode == 200) {
        await fetchCart();
        _isActionLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isActionLoading = false;
    notifyListeners();
    return false;
  }

  // hapus item dari keranjang
  Future<bool> removeItem(String cartItemId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final response = await _cartService.removeCartItem(cartItemId);
      if (response.statusCode == 200) {
        await fetchCart();
        _isActionLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isActionLoading = false;
    notifyListeners();
    return false;
  }

  // kosongkan seluruh keranjang
  Future<bool> clearCart() async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final response = await _cartService.clearCart();
      if (response.statusCode == 200) {
        _cart = CartModel(items: [], totalItems: 0, totalPrice: 0);
        _isActionLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isActionLoading = false;
    notifyListeners();
    return false;
  }

  // reset keranjang saat logout
  void resetCart() {
    _cart = null;
    _errorMessage = null;
    notifyListeners();
  }
}
