import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// General screens (inside vendors folder)
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
// Vendor screens
import 'screens/vendors/vendor_dashboard.dart';
import 'screens/vendors/menu_management_screen.dart';
import 'screens/vendors/add_business_screen.dart';
import 'screens/vendors/business_profile_screen.dart';

// Customer screens
import 'screens/customer/customer_dashboard.dart';
import 'screens/customer/vendor_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/order_success_screen.dart'; // ✅ Imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiThela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // General
        '/': (context) => const SplashScreen(),
        '/role': (context) => const RoleSelectionScreen(),
        '/login': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String?;
          return LoginScreen(role: role ?? 'vendor');
        },
        '/signup': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String?;
          return SignupScreen(role: role ?? 'vendor');
        },

        // Vendor
        '/seller_dashboard': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String?;
          return VendorDashboard(email: email ?? 'vendor@gmail.com');
        },
        '/menu_management': (context) => const MenuManagementScreen(),
        '/add_business': (context) => const AddBusinessScreen(),
        '/business_profile': (context) => const BusinessProfileScreen(),

        // Customer
        '/customer_dashboard': (context) => const CustomerDashboard(),
        '/customer_home': (context) => const CustomerDashboard(), // Optional alias
        '/vendor_detail': (context) {
          final vendorEmail = ModalRoute.of(context)!.settings.arguments as String;
          return VendorDetailScreen(vendorEmail: vendorEmail);
        },
        '/cart': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CartScreen(
            vendorEmail: args['vendorEmail'],
            cart: Map<String, int>.from(args['cart']),
          );
        },
        '/order_success': (context) => const OrderSuccessScreen(), // ✅ Registered
      },
    );
  }
}