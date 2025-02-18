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

//TODO Kuryelerin müsaitlik durumu için ayarlar kısmı ekle kim moladaysa soluk gözüksün..!!!

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
      // MongoDB'den kurye ve sipariş verilerini al
      final couriers = await MongoDatabase.getCouriersByRestaurantbyId(user!.id);
      final orders = await MongoDatabase.getOrdersByRestaurantbyId(user.id);
      
      // State güncelle
      setState(() {
        _couriers = couriers;
        _orders = orders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurant == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                      return GestureDetector(
                        onTap: () {
                          // Kurye tıklanma işlemleri
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
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isActiveOrder = order.status == 'Aktif Sipariş';

                      return Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isActiveOrder ? Colors.green : Colors.red,
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
              latitude: _restaurant!.restaurantLocation.latitude,
              longitude: _restaurant!.restaurantLocation.longitude,
              couriers: _couriers,
              restaurantName: _restaurant!.name,
              activeOrders: _orders
                  .where((order) => order.status == 'Aktif Sipariş')
                  .toList(),
              createOrder: false,
              onLocationSelected: (LatLng ) {  }, // HomeScreen'de sipariş oluşturma kapalı
            ),
          ),
        ],
      ),
    );
  }
}
