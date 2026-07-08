// konstanta global aplikasi e-commerce
class Constants {
  // base url api
  static const String apiBaseUrl = 'https://api-tb-f2wk.onrender.com/api';

  // key penyimpanan lokal
  static const String tokenStorageKey = 'ecommerce_jwt_token';
  static const String userRoleKey = 'ecommerce_user_role';

  // nama aplikasi
  static const String appTitle = 'TBPrak Shop';

  // batas pagination default
  static const int defaultPageLimit = 10;

  // batas minimum password
  static const int minPasswordLength = 6;

  // batas minimum alamat
  static const int minAddressLength = 10;

  // pesan error global
  static const String networkErrorMsg =
      'Gagal terhubung ke server. Periksa koneksi internet Anda.';
  static const String serverErrorMsg =
      'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
  static const String unauthorizedMsg =
      'Sesi Anda telah berakhir. Silakan login kembali.';
}
