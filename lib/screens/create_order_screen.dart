// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_courier/components/MapComponent.dart';
import 'package:flutter_courier/contexts/CartProvider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter_courier/contexts/web_socket_provider.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController _textController = TextEditingController();
  final WebviewController _controller = WebviewController();
  final List<StreamSubscription> _subscriptions = [];
  late MapComponent _mapcomponent;
  List<Courier> _couriers = [];
  Restaurant? _restaurant;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _initializeWebview();
  }

  Future<void> _initializeWebview() async {
    try {
      await _controller.initialize();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<WebSocketProvider>(context, listen: false);
      final user = authProvider.user;
      _restaurant = user!;
      final latitude = _restaurant!.restaurantLocation.latitude;
      final longitude = _restaurant!.restaurantLocation.longitude;
      // MongoDB'den kuryeleri al
      final couriers = await MongoDatabase.getCouriersByRestaurantbyId(user.id);
      if (kDebugMode) {
        print('Fetched couriers: $couriers');
      }

      final orders = await MongoDatabase.getOrdersByRestaurantbyId(user.id);
      final activeOrders =
          orders.where((order) => order.status == 'Aktif Sipariş').toList();

      _mapcomponent = MapComponent(
          latitude: latitude,
          longitude: longitude,
          couriers: couriers,
          restaurantName: user.name,
          activeOrders: activeOrders,
          controller: _controller);
      // Verileri kontrol edin
      final dataUrl = Uri.dataFromString(
        await _mapcomponent.generateHtmlContent(),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString();

      await _controller.loadUrl(dataUrl);

      // Kuryeleri state'e ekle
      setState(() {
        _orders = orders;
        debugPrint('Orders updated: $_orders');
        _couriers = couriers;
        debugPrint('Couriers updated: $_couriers');
        _restaurant = user;
        debugPrint('Restaurant updated: $_restaurant');
      });

      if (_subscriptions.isNotEmpty) {
        for (var s in _subscriptions) {
          s.cancel();
        }
        _subscriptions.clear();
      }

      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      if (!mounted) return;
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${e.code}'),
                Text('Message: ${e.message}'),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  if (_restaurant == null) {
    return const Center(
      child: CircularProgressIndicator(), // Restoran verisi yüklenmediğinde yükleme göstergesi
    );
  }
  return Scaffold(
    appBar: AppBar(
      title: const Text('Sipariş Oluştur'),
    ),
    body: Row(
      children: [
        // Sol taraf: Kurye listesi ve ürün listesi
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Kurye listesi
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _couriers.length,
                  itemBuilder: (context, index) {
                    final courier = _couriers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(courier.name),
                        subtitle: Text('Aktiflik: ${courier.active}'),
                        onTap: () {
                          // Kurye seçildiğinde işlem yapılabilir
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(thickness: 2), // Ayrım çizgisi
              // Ürün listesi
              Expanded(
                flex: 1,
                child: Consumer<CartProvider>(
                  builder: (ctx, cart, _) => ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items.values.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(cartItem.title),
                          subtitle: Text('Adet: ${cartItem.quantity}, Fiyat: ${cartItem.price}₺'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(thickness: 2, width: 2), // Ayrım çizgisi
        // Sağ taraf: Harita
        Expanded(
          flex: 2,
          child: MapComponent(
            latitude: _restaurant!.restaurantLocation.latitude,
            longitude: _restaurant!.restaurantLocation.longitude,
            couriers: _couriers,
            restaurantName: _restaurant!.name,
            activeOrders: _orders
                .where((order) => order.status == 'Aktif Sipariş')
                .toList(),
            controller: _controller,
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Sipariş oluşturma işlemi burada yapılabilir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sipariş oluşturuldu!'),
          ),
        );
      },
      child: const Icon(Icons.check),
    ),
  );
}

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    return WebviewPermissionDecision.allow; // İzin verilmesi durumu
  }
}
