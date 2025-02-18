// To parse this JSON data, do

import 'dart:convert';

import 'package:flutter_courier/contexts/CartProvider.dart';
import 'package:flutter_courier/models/location.dart';
import 'package:mongo_dart/mongo_dart.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  ObjectId id;
  String customer;
  String status;
  List<CartItem> products;  // Yeni eklenen alan
  DateTime date;
  Location customerLocation;
  ObjectId courierId;
  ObjectId restaurantId;

  Order({
    required this.id,
    required this.customer,
    required this.products,
    required this.status,
    required this.date,
    required this.customerLocation,
    required this.courierId,
    required this.restaurantId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["_id"],
        customer: json["customer"],
        status: json["status"],
        products: List<CartItem>.from( json["products"].map((x) => CartItem.fromJson(x))), // products alanını parse etme
        date: json["date"], // $date ile gelen tarihi parse ediyoruz
        customerLocation: Location.fromJson(json["customerLocation"]),
        courierId: json["courierID"],
        restaurantId: json["restaurantID"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "customer": customer,
        "status": status,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "date": date.toIso8601String(),
        "customerLocation": customerLocation.toJson(),
        "courierID": courierId,
        "restaurantID": restaurantId,
      };
}
