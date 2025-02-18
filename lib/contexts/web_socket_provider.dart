// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/location.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketProvider with ChangeNotifier {
  final String url;
  late WebSocketChannel channel;
  final Map<String, Courier> couriers = {}; // Kuryeleri ID'ye göre sakla
  final StreamController<Map<String, Courier>> _courierController = StreamController.broadcast();

  WebSocketProvider(this.url) {
    _connect();
  }

  // Kuryelerin güncel konumlarını dinlemek için dışa açık stream
  Stream<Map<String, Courier>> get courierStream => _courierController.stream;

  void _connect() {
    channel = WebSocketChannel.connect(Uri.parse(url));
    debugPrint('WebSocket bağlantısı kuruldu');

    channel.stream.listen(
      (message) {
        debugPrint('Gelen mesaj: $message');
        _handleIncomingMessage(message);
      },
      onError: (error) {
        debugPrint('WebSocket hata: $error');
        _reconnect();
      },
      onDone: () {
        debugPrint('WebSocket bağlantısı kapandı');
        _reconnect();
      },
    );
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      debugPrint('WebSocket yeniden bağlanıyor...');
      _connect();
    });
  }

  void _handleIncomingMessage(String message) {
    try {
      final data = jsonDecode(message);
      debugPrint('Decoded data: $data');

      if (data is Map<String, dynamic> &&
          data.containsKey('courierObjectId') &&
          data.containsKey('latitude') &&
          data.containsKey('longitude')) {
        final courierId = data['courierObjectId'];
        final latitude = data['latitude'];
        final longitude = data['longitude'];

        _updateCourierLocation(courierId, latitude, longitude);
      } else {
        debugPrint('Gelen veri beklenen formatta değil: $data');
      }
    } catch (e) {
      debugPrint('Veri işleme hatası: $e');
    }
  }

  void _updateCourierLocation(String courierId, double latitude, double longitude) {
    if (couriers.containsKey(courierId)) {
      // Mevcut kurye konumunu güncelle
      couriers[courierId]?.updateLocation(latitude, longitude);
    } else {
      // Yeni kurye oluştur ve ekle
      couriers[courierId] = Courier(
        id: ObjectId.fromHexString(courierId),
        nickname: '',
        password: '',
        restaurantId: ObjectId(),
        orders: [],
        active: '',
        currentLocation: Location(latitude: latitude, longitude: longitude),
        name: '',
      );
    }

    // Güncel kurye verilerini stream'e gönder
    _courierController.add(Map<String, Courier>.from(couriers));
    notifyListeners();
  }

  // Kurye konumu gönderme
  void sendLocation(Courier courier) {
    final dataToSend = {
      'courierObjectId': courier.id.toHexString(),
      'latitude': courier.currentLocation.latitude,
      'longitude': courier.currentLocation.longitude,
    };
    channel.sink.add(jsonEncode(dataToSend));
  }

  @override
  void dispose() {
    channel.sink.close();
    _courierController.close();
    super.dispose();
  }
}
