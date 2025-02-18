import 'package:flutter/foundation.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:mongo_dart/mongo_dart.dart'; // MongoDB için gerekli kütüphane


class CartProvider with ChangeNotifier {
  Map<ObjectId, CartItem> _items = {}; // Sepetteki ürünleri tutan harita

  Map<ObjectId, CartItem> get items => _items;

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    // Toplam fiyatı hesapla
    return _items.values.fold(0.0, (total, item) => total + item.price * item.quantity);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Eğer ürün zaten sepette varsa, miktarını artır
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      // Eğer ürün sepette yoksa yeni ürün ekle
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id, // ObjectId'yi string olarak sakla
          title: product.productTitle,
          quantity: 1,
          price: product.productPrice,
        ),
      );
    }
    notifyListeners(); // Değişiklikleri dinleyenlere bildir
  }

  void removeItem(ObjectId productId) {
    _items.remove(productId);
    notifyListeners(); // Değişiklikleri dinleyenlere bildir
  }

  void clearCart() {
    _items = {};
    notifyListeners(); // Değişiklikleri dinleyenlere bildir
  }

  // Sepetteki bir ürünün miktarını azalt
  void removeSingleItem(ObjectId productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productId); // Miktar 1 ise ürünü tamamen kaldır
    }
    notifyListeners();
  }
}

class CartItem {
  final ObjectId id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  // fromJson Fonksiyonu
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'], // id'nin ObjectId türünde olduğunu unutmayın
      title: json['title'],
      quantity: json['quantity'],
      price: json['price'].toDouble(), // fiyatın double olması gerektiğini unutmayın
    );
  }

  // toJson Fonksiyonu
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }
}
