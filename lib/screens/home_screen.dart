// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/contexts/web_socket_provider.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'package:flutter_courier/components/MapComponent.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final WebviewController _controller = WebviewController();
  Restaurant? _restaurant;
  late MapComponent _mapcomponent;
  final List<StreamSubscription> _subscriptions = [];
  List<Courier> _couriers = [];
  List<Order> _orders = [];
  

  @override
  void initState() {
    super.initState();
    _initializeWebview();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ekran ilk kez oluşturulduğunda yapılacak işlemler
    });
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
      final couriers =
          await MongoDatabase.getCouriersByRestaurantbyId(user.id);
      if (kDebugMode) {
        print('Fetched couriers: $couriers');
      }

      final orders = await MongoDatabase.getOrdersByRestaurantbyId(user.id);
      final activeOrders =
          orders.where((order) => order.status == 'Aktif Sipariş').toList();

      _mapcomponent = MapComponent(latitude: latitude, longitude: longitude, couriers: couriers, restaurantName: user.name, activeOrders: activeOrders, controller: _controller);
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
    for (var s in _subscriptions) {
      s.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurant == null) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Restoran verisi yüklenmediğinde yükleme göstergesi
    }
    debugPrint(
        'Kuryeler listesi: $_couriers'); // Kuryeler listesini kontrol edin

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _couriers.length,
                    itemBuilder: (context, index) {
                      final courier = _couriers[index];
                      final isActiveCourier = courier.active == "Boşta";
                      final isOnWay = courier.active == "Yolda";
                      return GestureDetector(
                        onTap: () {
                          // Kurye tıklandığında yapılacak işlemler
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isActiveCourier
                                ? Colors.green
                                : isOnWay
                                    ? Colors.blue
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kurye: ${courier.name}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Aktiflik: ${courier.active}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  height: 2,
                  color: Colors.blue,
                  thickness: 5.0,
                ), // Çizgi ekleyin

                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _orders.length, // Siparişler listesi
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isActiveOrder = order.status == 'Aktif Sipariş';

                      return Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isActiveOrder
                              ? Colors.green
                              : Colors.red, // Siparişler için renk
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sipariş ID: ${order.id}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Müşteri İsim: ${order.customer}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Durum: ${order.status}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Tarih: ${order.date}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: MapComponent(
              latitude: _restaurant!.restaurantLocation.latitude ,
              longitude: _restaurant!.restaurantLocation.longitude , // Restoranın boylam değeri,
              couriers: _couriers,
              restaurantName: _restaurant!.name , // Restoran adı,
              activeOrders: _orders.where((order) => order.status == 'Aktif Sipariş').toList(),
              controller: _controller, // Dışarıda başlatılmış controller
            ),
          ),
        ],
      ),
    );
  }

}
