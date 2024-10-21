// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_courier/models/location.dart';
import 'package:mongo_dart/mongo_dart.dart';

Restaurant restaurantFromJson(String str) => Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
    ObjectId id;
    List<ObjectId> orders;
    String name;
    List<ObjectId> couriersIDs;
    Location restaurantLocation;
    String nickname;
    String password;
    List<Model> models;

    Restaurant({
        required this.id,
        required this.orders,
        required this.name,
        required this.couriersIDs,
        required this.restaurantLocation,
        required this.nickname,
        required this.password,
        required this.models,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["_id"],
        orders: List<ObjectId>.from(json["orders"].map((x) => x)),
        name: json["name"],
        couriersIDs: List<ObjectId>.from(json["couriersIDs"].map((x) => x)),
        restaurantLocation: Location.fromJson(json["restaurantLocation"]),
        nickname: json["nickname"],
        password: json["password"],
        models: List<Model>.from(json["models"].map((x) => Model.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "orders": List<dynamic>.from(orders.map((x) => x)),
        "name": name,
        "couriersIDs": List<dynamic>.from(couriersIDs.map((x) => x)),
        "restaurantLocation": restaurantLocation.toJson(),
        "nickname": nickname,
        "password": password,
        "models": List<dynamic>.from(models.map((x) => x.toJson())),
    };
}


class Model {
    ObjectId id;
    String modelTitle;
    List<Product> products;

    Model({
        required this.id,
        required this.modelTitle,
        required this.products,
    });

    factory Model.fromJson(Map<String, dynamic> json) => Model(
        id: json["_id"],
        modelTitle: json["modelTitle"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "modelTitle": modelTitle,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

class Product {
    ObjectId id;
    String productTitle;
    String productImage;
    double productPrice;

    Product({
        required this.id,
        required this.productTitle,
        required this.productImage,
        required this.productPrice,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"],
        productTitle: json["productTitle"],
        productImage: json["productImage"],
        productPrice: json["productPrice"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "productTitle": productTitle,
        "productImage": productImage,
        "productPrice": productPrice,
    };
}
