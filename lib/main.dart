// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_courier/contexts/CartProvider.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/navigation/custom_drawer.dart';
import 'package:flutter_courier/screens/create_order_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter_courier/contexts/web_socket_provider.dart'; // WebSocketProvider'ı import edin
import 'package:flutter_courier/screens/home_screen.dart';
import 'package:flutter_courier/screens/login_screen.dart';
import 'package:flutter_courier/screens/options_screen.dart';
import 'package:flutter_courier/screens/order_screen.dart';
import 'screens/Platforms/GetirScreen.dart';
import 'screens/Platforms/YemeksepetiScreen.dart';
import 'screens/Platforms/TrendyolScreen.dart';
import 'data/data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketProvider('ws://$ip:3000')), // WebSocketProvider'ı ekleyin
        ChangeNotifierProvider(create: (_) => CartProvider()), // CartProvider ekle
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Courier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // İlk ekran olarak LoginScreen ayarlandı
      routes: {
        '/main': (context) => const MainScreen(), // MainScreen yönlendirmesi
        '/options': (context) => const OptionsScreen(),
        '/orders': (context) => const OrderScreen(),
        '/login': (context) => const LoginScreen(),
        '/yemeksepeti': (context) => const YemeksepetiScreen(),
        '/getir': (context) => const GetirScreen(),
        '/trenyol': (context) => const TrendyolScreen(),
        '/createOrder' : (context) => const CreateOrderScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrderScreen(),
    const OptionsScreen(),
    const YemeksepetiScreen(),
    const GetirScreen(),
    const TrendyolScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketProvider>(
      builder: (context, webSocketProvider, child) {
        return Scaffold(
          body: Row(
            children: [
              CustomDrawer(
                onMenuItemSelected: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
