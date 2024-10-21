import 'dart:developer';

import 'package:flutter_courier/dbHelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:flutter_courier/models/restaurant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection couriersCollection;
  static late DbCollection ordersCollection;
  static late DbCollection restaurantsCollection;

  static Future<void> connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    couriersCollection = db.collection(COURIERS_COLLECTION);
    ordersCollection = db.collection(ORDERS_COLLECTION);
    restaurantsCollection = db.collection(RESTAURANTS_COLLECTION);
  }

  // Fetch all restaurants
  static Future<List<Restaurant>> getAllRestaurants() async {
    final arrData = await restaurantsCollection.find().toList();
    return arrData.map((json) => Restaurant.fromJson(json)).toList();
  }

  // Fetch a single restaurant by ID
  static Future<Restaurant?> getRestaurantById(ObjectId id) async {
    final json = await restaurantsCollection.findOne(where.id(id));
    return json != null ? Restaurant.fromJson(json) : null;
  }

  // Fetch all couriers
  static Future<List<Courier>> getAllCouriers() async {
    final arrData = await couriersCollection.find().toList();
    return arrData.map((json) => Courier.fromJson(json)).toList();
  }

  // Fetch a single courier by ID
  static Future<Courier?> getCourierById(ObjectId id) async {
    final json = await couriersCollection.findOne(where.id(id));
    return json != null ? Courier.fromJson(json) : null;
  }

  // Fetch all orders
  static Future<List<Order>> getAllOrders() async {
    final arrData = await ordersCollection.find().toList();
    return arrData.map((json) => Order.fromJson(json)).toList();
  }

  // Fetch a single order by ID
  static Future<Order?> getOrderById(ObjectId id) async {
    final json = await ordersCollection.findOne(where.id(id));
    return json != null ? Order.fromJson(json) : null;
  }

    // Fetch orders by restaurant ID
  static Future<List<Order>> getOrdersByRestaurantbyId(ObjectId restaurantId) async {
    final restaurant = await getRestaurantById(restaurantId); 
    // If orderIds are already ObjectId, just use them directly
    final orderIds = restaurant?.orders; // Assuming restaurant.orders is already List<ObjectId>

  final List<Order> orders = [];

  for (var id in orderIds!) {
    final order = await getOrderById(id);
    if (order != null) {
      orders.add(order);
    }
  }

  return orders;
  }

      // Fetch orders by restaurant ID
  static Future<List<Courier>> getCouriersByRestaurantbyId(ObjectId restaurantId) async {
    final restaurant = await getRestaurantById(restaurantId); 
    // If orderIds are already ObjectId, just use them directly
    final courierIds = restaurant?.couriersIDs; // Assuming restaurant.orders is already List<ObjectId>

  final List<Courier> couriers = [];

  for (var id in courierIds!) {
    final courier = await getCourierById(id);
    if (courier != null) {
      couriers.add(courier);
    }
  }
  return couriers;
  }
}
