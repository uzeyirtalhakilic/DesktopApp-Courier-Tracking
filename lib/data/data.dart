//data.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';

const String ip = '192.168.1.124';

// ignore: constant_identifier_names
const String API_URL = 'http://$ip:3000';

// Restoran fonksiyonları
Future<List<Restaurant>> fetchRestaurants() async {
  final response = await http.get(Uri.parse('$API_URL/restaurants'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Restaurant.fromJson(json)).toList();
  } else {
    throw Exception('Restoranları getirirken bir hata oluştu.');
  }
}

Future<Restaurant> fetchRestaurantById(String id) async {
  final response = await http.get(Uri.parse('$API_URL/restaurants/$id'));

  if (response.statusCode == 200) {
    return Restaurant.fromJson(json.decode(response.body));
  } else {
    throw Exception('Restoran getirirken bir hata oluştu.');
  }
}

Future<Restaurant> createRestaurant(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$API_URL/restaurants'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 201) {
    return Restaurant.fromJson(json.decode(response.body));
  } else {
    throw Exception('Restoran eklerken bir hata oluştu.');
  }
}

Future<Restaurant> updateRestaurant(String id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$API_URL/restaurants/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    return Restaurant.fromJson(json.decode(response.body));
  } else {
    throw Exception('Restoranı güncellerken bir hata oluştu.');
  }
}

Future<void> deleteRestaurant(String id) async {
  final response = await http.delete(Uri.parse('$API_URL/restaurants/$id'));

  if (response.statusCode != 200) {
    throw Exception('Restoran silerken bir hata oluştu. ID: $id');
  }
}

// Kurye fonksiyonları
Future<List<Courier>> fetchCouriers() async {
  final response = await http.get(Uri.parse('$API_URL/couriers'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Courier.fromJson(item as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Kuryeleri getirirken bir hata oluştu.');
  }
}


Future<Courier?> fetchCourierById(String courierId) async {
  try {
    final response = await http.get(Uri.parse('$API_URL/couriers/$courierId'));

    if (response.statusCode == 200) {
      return Courier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load courier');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching courier: $e');
    }
    return null;
  }
}




Future<Courier> createCourier(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$API_URL/couriers'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 201) {
    return Courier.fromJson(json.decode(response.body));
  } else {
    throw Exception('Kurye eklerken bir hata oluştu.');
  }
}

Future<Courier> updateCourier(String id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$API_URL/couriers/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    return Courier.fromJson(json.decode(response.body));
  } else {
    throw Exception('Kuryeyi güncellerken bir hata oluştu.');
  }
}

Future<void> deleteCourier(String id) async {
  final response = await http.delete(Uri.parse('$API_URL/couriers/$id'));

  if (response.statusCode != 200) {
    throw Exception('Kurye silerken bir hata oluştu. ID: $id');
  }
}

// Sipariş fonksiyonları
Future<List<Order>> fetchOrders() async {
  final response = await http.get(Uri.parse('$API_URL/orders'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Order.fromJson(json)).toList();
  } else {
    throw Exception('Siparişleri getirirken bir hata oluştu.');
  }
}

Future<Order> fetchOrderById(String id) async {
  final response = await http.get(Uri.parse('$API_URL/orders/$id'));

  if (response.statusCode == 200) {
    return Order.fromJson(json.decode(response.body));
  } else {
    throw Exception('Siparişi getirirken bir hata oluştu.');
  }
}


Future<Order> createOrder(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$API_URL/orders'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 201) {
    return Order.fromJson(json.decode(response.body));
  } else {
    throw Exception('Sipariş eklerken bir hata oluştu.');
  }
}

Future<Order> updateOrder(String id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$API_URL/orders/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    return Order.fromJson(json.decode(response.body));
  } else {
    throw Exception('Siparişi güncellerken bir hata oluştu.');
  }
}

Future<void> deleteOrder(String id) async {
  final response = await http.delete(Uri.parse('$API_URL/orders/$id'));

  if (response.statusCode != 200) {
    throw Exception('Sipariş silerken bir hata oluştu. ID: $id');
  }
}
