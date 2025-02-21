// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_courier/components/MapComponent.dart';
import 'package:flutter_courier/contexts/CartProvider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

//TODO Veritabanında Ordersı güncelle. Sipariş ekleye basınca order eklenmesini sağla.

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  List<Courier> _couriers = [];
  Restaurant? _restaurant;
  List<Order> _orders = [];
  LatLng? selectedLocation; // Seçilen koordinatlar için değişken
  Courier? _selectedCourier; // Seçilen kurye için değişken

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _restaurant = user!;

    // MongoDB'den kuryeleri ve siparişleri al
    final couriers = await MongoDatabase.getCouriersByRestaurantbyId(user.id);
    final orders = await MongoDatabase.getOrdersByRestaurantbyId(user.id);
    final activeOrders =
        orders.where((order) => order.status == 'Aktif Sipariş').toList();

    setState(() {
      _orders = activeOrders;
      _couriers = couriers;
      _restaurant = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurant == null) {
      return const Center(
        child: CircularProgressIndicator(),
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
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _couriers.length,
                    itemBuilder: (context, index) {
                      final courier = _couriers[index];
                      final isSelected = courier == _selectedCourier;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: isSelected ? Colors.blue.shade100 : null, // Seçilen kuryeyi renklendir
                        child: ListTile(
                          title: Text(courier.name),
                          subtitle: Text('Aktiflik: ${courier.active}'),
                          onTap: () {
                            setState(() {
                              _selectedCourier = courier; // Seçilen kuryeyi tut
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(thickness: 2),
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
                            subtitle: Text(
                                'Adet: ${cartItem.quantity}, Fiyat: ${cartItem.price}₺'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 2, width: 2),
          Expanded(
            flex: 2,
            child: MapComponent(
              latitude: _restaurant!.restaurantLocation.latitude,
              longitude: _restaurant!.restaurantLocation.longitude,
              couriers: _couriers,
              restaurantName: _restaurant!.name,
              activeOrders: _orders,
              createOrder: true,
              onLocationSelected: (LatLng location) {
                setState(() {
                  selectedLocation = location;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null && _selectedCourier != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sipariş konumu: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}, Kurye: ${_selectedCourier!.name}',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lütfen bir konum ve kurye seçin.'),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
