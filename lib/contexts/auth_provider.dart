import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_courier/models/restaurant.dart'; // Restaurant modelini içe aktar
// Location modelini içe aktar
// MongoDB ObjectId desteği
import 'package:flutter_courier/dbHelper/mongodb.dart'; // MongoDatabase sınıfını içe aktar

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Restaurant> _restaurants = [];
  Restaurant? _user;
  bool _isLoading = true;

  Restaurant? get user => _user;
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeData();
  }

    Future<void> _initializeData() async {
      await MongoDatabase.connect();
      await _loadRestaurants();
      _isLoading = false;
      notifyListeners();
    }

Future<void> _loadRestaurants() async {
  try {
    final restaurantData = await MongoDatabase.getAllRestaurants();
    _restaurants = restaurantData.cast<Restaurant>();
    notifyListeners();
  } catch (e, stacktrace) {
    if (kDebugMode) {
      print("Error loading restaurants: $e");
      print(stacktrace);
    }
  }
}
  Future<String> _hashPassword(String password) async {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> login(String nickname, String password) async {
    try {
      if (_restaurants.isEmpty) {
        await _loadRestaurants();
      }

      final hashedPassword = await _hashPassword(password);

      // Kullanıcıları filtrele
      final matchingRestaurants = _restaurants.where(
        (r) => r.nickname == nickname && r.password == hashedPassword,
      ).toList();

      // Eşleşen kullanıcı varsa, ilkini al
      if (matchingRestaurants.isNotEmpty) {
        final foundRestaurant = matchingRestaurants.first;
        _user = foundRestaurant;
        await _storage.write(key: 'user', value: jsonEncode(foundRestaurant.toJson()));
        notifyListeners();
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Kullanıcı bulunamadı veya şifre yanlış'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      return {'success': false, 'message': 'Giriş hatası'};
    }
  }


  Future<void> logout() async {
    try {
      await _storage.delete(key: 'user');
      _user = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }
}
