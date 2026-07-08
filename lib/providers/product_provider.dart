import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/models/category_model.dart';
import 'package:tb_ecommerce/models/product_model.dart';
import 'package:tb_ecommerce/services/product_service.dart';

// provider state management produk & katalog
class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = []; // daftar produk
  List<CategoryModel> _categories = []; // daftar kategori
  ProductModel? _selectedProduct; // produk detail

  bool _isLoading = false; // status loading list
  bool _isLoadingMore = false; // status loading pagination
  bool _isLoadingDetail = false; // status loading detail
  String? _errorMessage; // pesan error
  String? _detailError; // pesan error detail

  int _currentPage = 1; // halaman saat ini
  int _totalPages = 1; // total halaman
  bool _hasMore = true; // masih ada data

  String? _searchQuery; // kata kunci pencarian
  String? _selectedCategoryId; // filter kategori
  String? _selectedSort; // sorting aktif

  // getter
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  String? get detailError => _detailError;
  bool get hasMore => _hasMore;
  String? get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSort => _selectedSort;

  // fetch data products (halaman pertama)
  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products = [];
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getProducts(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        sort: _selectedSort,
        page: _currentPage,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _products = dataList
            .map((json) => ProductModel.fromJson(json))
            .toList();

        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPages'] ?? 1;
          _hasMore = _currentPage < _totalPages;
        }
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
    }
    _isLoading = false;
    notifyListeners();
  }

  // load more products (infinite scroll)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    try {
      final response = await _productService.getProducts(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        sort: _selectedSort,
        page: _currentPage,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _products.addAll(
          dataList.map((json) => ProductModel.fromJson(json)),
        );

        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPages'] ?? 1;
          _hasMore = _currentPage < _totalPages;
        }
      }
    } catch (e) {
      _currentPage--;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  // set search query dan reload
  void setSearchQuery(String? query) {
    _searchQuery = query;
    fetchProducts(refresh: true);
  }

  // set filter kategori dan reload
  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProducts(refresh: true);
  }

  // set sorting dan reload
  void setSortOrder(String? sort) {
    _selectedSort = sort;
    fetchProducts(refresh: true);
  }

  // reset semua filter
  void resetFilters() {
    _searchQuery = null;
    _selectedCategoryId = null;
    _selectedSort = null;
    fetchProducts(refresh: true);
  }

  // fetch daftar kategori
  Future<void> fetchCategories() async {
    try {
      final response = await _productService.getCategories();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        _categories = dataList
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal fetch kategori: $e');
    }
  }

  // fetch detail produk
  Future<void> fetchProductDetail(String productId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      final response = await _productService.getProductDetail(productId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        _selectedProduct = ProductModel.fromJson(response.data['data']);
      }
    } on DioException catch (e) {
      _detailError = DioEcommerceClient.parseErrorMessage(e);
    } catch (e) {
      _detailError = 'Gagal memuat detail produk.';
    }
    _isLoadingDetail = false;
    notifyListeners();
  }

  // clear detail produk
  void clearSelectedProduct() {
    _selectedProduct = null;
  }
}
