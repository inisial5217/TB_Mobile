import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/models/order_model.dart';
import 'package:tb_ecommerce/services/order_service.dart';

// provider state management pesanan
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = []; // daftar pesanan user
  List<OrderModel> _adminOrders = []; // daftar pesanan admin
  OrderModel? _selectedOrder; // detail pesanan
  bool _isLoading = false; // status loading
  bool _isLoadingMore = false; // status loading pagination
  bool _isCheckingOut = false; // status loading checkout
  bool _isUpdatingStatus = false; // status loading update status
  String? _errorMessage; // pesan error
  String? _detailError; // error detail

  int _currentPage = 1; // halaman user
  bool _hasMore = true;
  int _adminPage = 1; // halaman admin
  bool _adminHasMore = true;
  String? _adminStatusFilter; // filter status admin

  // getter
  List<OrderModel> get orders => _orders;
  List<OrderModel> get adminOrders => _adminOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isCheckingOut => _isCheckingOut;
  bool get isUpdatingStatus => _isUpdatingStatus;
  String? get errorMessage => _errorMessage;
  String? get detailError => _detailError;
  bool get hasMore => _hasMore;
  bool get adminHasMore => _adminHasMore;
  String? get adminStatusFilter => _adminStatusFilter;

  // checkout - buat pesanan baru
  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
  }) async {
    _isCheckingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
      );
      _isCheckingOut = false;
      notifyListeners();
      return response.statusCode == 201 || response.data['success'] == true;
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  // fetch riwayat pesanan user
  Future<void> fetchMyOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _orders = [];
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.getMyOrders(page: _currentPage);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _orders = dataList
            .map((json) => OrderModel.fromJson(json))
            .toList();
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _hasMore = _currentPage < (pagination['totalPages'] ?? 1);
        }
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  // load more pesanan user
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    try {
      final response = await _orderService.getMyOrders(page: _currentPage);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _orders.addAll(
            dataList.map((json) => OrderModel.fromJson(json)));
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _hasMore = _currentPage < (pagination['totalPages'] ?? 1);
        }
      }
    } catch (e) {
      _currentPage--;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  // fetch detail pesanan
  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _detailError = null;
    _selectedOrder = null;
    notifyListeners();

    try {
      final response = await _orderService.getOrderDetail(orderId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        _selectedOrder = OrderModel.fromJson(response.data['data']);
      }
    } on DioException catch (e) {
      _detailError = DioEcommerceClient.parseErrorMessage(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  // === ADMIN METHODS ===

  // set filter status admin
  void setAdminStatusFilter(String? status) {
    _adminStatusFilter = status;
    fetchAdminOrders(refresh: true);
  }

  // fetch semua pesanan (admin)
  Future<void> fetchAdminOrders({bool refresh = false}) async {
    if (refresh) {
      _adminPage = 1;
      _adminHasMore = true;
      _adminOrders = [];
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.getAllOrders(
        status: _adminStatusFilter,
        page: _adminPage,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _adminOrders = dataList
            .map((json) => OrderModel.fromJson(json))
            .toList();
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _adminHasMore = _adminPage < (pagination['totalPages'] ?? 1);
        }
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  // load more pesanan admin
  Future<void> loadMoreAdminOrders() async {
    if (_isLoadingMore || !_adminHasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    _adminPage++;
    try {
      final response = await _orderService.getAllOrders(
        status: _adminStatusFilter,
        page: _adminPage,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _adminOrders.addAll(
            dataList.map((json) => OrderModel.fromJson(json)));
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _adminHasMore = _adminPage < (pagination['totalPages'] ?? 1);
        }
      }
    } catch (e) {
      _adminPage--;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  // update status pesanan (admin)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isUpdatingStatus = true;
    notifyListeners();

    try {
      final response = await _orderService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
      _isUpdatingStatus = false;
      if (response.statusCode == 200) {
        // refresh data pesanan admin
        await fetchAdminOrders(refresh: true);
        return true;
      }
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  // reset pesanan saat logout
  void resetOrders() {
    _orders = [];
    _adminOrders = [];
    _selectedOrder = null;
    _errorMessage = null;
    notifyListeners();
  }
}
