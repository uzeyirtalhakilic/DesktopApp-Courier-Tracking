// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'dart:async';
import 'package:flutter_courier/components/MapComponent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Restaurant? _restaurant;
  List<Courier> _couriers = [];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _restaurant = user;

    if (_restaurant != null) {
      final couriers = await MongoDatabase.getCouriersByRestaurantbyId(user!.id);
      final orders = await MongoDatabase.getOrdersByRestaurantbyId(user.id);
      
      setState(() {
        _couriers = couriers;
        _orders = orders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurant == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                      return Card(
                        color: isActiveCourier
                            ? Colors.deepOrange.shade700
                            : isOnWay
                                ? Colors.redAccent.shade700
                                : Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            courier.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Durum: ${courier.active}",
                            style: TextStyle(color: Colors.grey.shade300),
                          ),
                          leading: const Icon(Icons.motorcycle, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.deepOrange, thickness: 4.0),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isActiveOrder = order.status == 'Aktif Sipariş';
                      return Card(
                        color: isActiveOrder ? Colors.redAccent.shade700 : Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            'Sipariş: ${order.id}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Müşteri: ${order.customer}', style: TextStyle(color: Colors.grey.shade300)),
                              Text('Durum: ${order.status}', style: TextStyle(color: Colors.grey.shade300)),
                              Text('Tarih: ${order.date}', style: TextStyle(color: Colors.grey.shade300)),
                            ],
                          ),
                          leading: const Icon(Icons.shopping_bag, color: Colors.white),
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
              latitude: _restaurant!.restaurantLocation.latitude,
              longitude: _restaurant!.restaurantLocation.longitude,
              couriers: _couriers,
              restaurantName: _restaurant!.name,
              activeOrders: _orders.where((order) => order.status == 'Aktif Sipariş').toList(),
              createOrder: false,
              onLocationSelected: (LatLng) {},
            ),
          ),
        ],
      ),
    );
  }
}