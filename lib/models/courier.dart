// To parse this JSON data, do
//
//     final courier = courierFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_courier/models/location.dart';
import 'package:mongo_dart/mongo_dart.dart';

Courier courierFromJson(String str) => Courier.fromJson(json.decode(str));

String courierToJson(Courier data) => json.encode(data.toJson());

class Courier {
    ObjectId id;
    String name;
    String nickname;
    String password;
    String active;
    ObjectId restaurantId;
    List<ObjectId> orders;
    Location currentLocation;

    Courier({
        required this.id,
        required this.nickname,
        required this.password,
        required this.restaurantId,
        required this.orders,
        required this.active,
        required this.currentLocation,
        required this.name,
    });

    factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["_id"],
        nickname: json["nickname"],
        password: json["password"],
        restaurantId: json["restaurantID"],
        orders: List<ObjectId>.from(json["orders"].map((x) => x)),
        active: json["active"],
        currentLocation: Location.fromJson(json["currentLocation"]),
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "nickname": nickname,
        "password": password,
        "restaurantID": restaurantId,
        "orders": List<dynamic>.from(orders.map((x) => x)),
        "active": active,
        "currentLocation": currentLocation.toJson(),
        "name": name,
    };
  @override
  String toString() {
    return 'Courier(name: $name, active: $active)';
  }
  void updateLocation(double latitude, double longitude) {
    currentLocation = Location(latitude: latitude, longitude: longitude);
  }
}
