// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/dbHelper/mongodb.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> _orders = [];
  late Restaurant _restaurant;

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Siparişleri ilk başta yükle
  }

  Future<void> _fetchOrders() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final restaurant = authProvider.user;
      _restaurant = restaurant!;
      final orders = await MongoDatabase.getOrdersByRestaurantbyId(restaurant.id); // Restoran ID'yi dinamik yapabilirsiniz
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Hata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final isActiveOrder = order.status == 'Aktif Sipariş'; // Siparişin durumu

                return GestureDetector(
                  onTap: () {
                    // Sipariş tıklandığında yapılacak işlemler
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isActiveOrder ? Colors.redAccent.shade700 : Colors.grey.shade800,
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
                          'Restoran: ${_restaurant.name}', // Restoran adı
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Müşteri: ${order.customer}', // Müşteri adı
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Durum: ${order.status}', // Sipariş durumu
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Tarih: ${order.date}', // Sipariş tarihi
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
