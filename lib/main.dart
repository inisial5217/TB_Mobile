import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/constants.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/providers/auth_provider.dart';
import 'package:tb_ecommerce/providers/cart_provider.dart';
import 'package:tb_ecommerce/providers/dashboard_provider.dart';
import 'package:tb_ecommerce/providers/order_provider.dart';
import 'package:tb_ecommerce/providers/product_provider.dart';
import 'package:tb_ecommerce/screens/auth/login_screen.dart';
import 'package:tb_ecommerce/screens/auth/splash_screen.dart';

// navigator key global untuk redirect saat force logout
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // atur orientasi potret saja
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // atur warna status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // setup interceptor untuk force logout 401
  DioEcommerceClient().onUnauthorized = () {
    // bersihkan provider dan arahkan ke login
    if (navigatorKey.currentContext != null) {
      final context = navigatorKey.currentContext!;
      context.read<CartProvider>().resetCart();
      context.read<OrderProvider>().resetOrders();
      
      // show session expired message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );

      // redirect
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  };

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: Constants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
