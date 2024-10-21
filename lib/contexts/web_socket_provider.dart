// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_courier/data/data.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/location.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketProvider with ChangeNotifier {
  final WebSocketChannel channel;
  final Map<String, Courier> couriers = {}; // Kuryeleri ID'ye göre saklayın

  WebSocketProvider(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url)) {
    debugPrint('WebSocket bağlantısı kuruldu');

    channel.stream.listen(
      (message) {
        debugPrint('Gelen mesaj: $message');
        _handleIncomingMessage(message);
      },
      onError: (error) {
        debugPrint('WebSocket hata: $error');
      },
      onDone: () {
        debugPrint('WebSocket bağlantısı kapandı');
        reconnect();
      },
    );
  }
void reconnect() {
  Future.delayed(Duration(seconds: 5), () {
    WebSocketProvider('ws://$ip:3000');// 5 saniye sonra tekrar dene
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
      couriers[courierId]?.updateLocation(latitude, longitude);
    } else {
      couriers[courierId] = Courier(
        id: ObjectId.fromHexString(courierId),
        nickname: '', // Varsayılan değer
        password: '', // Varsayılan değer
        restaurantId: ObjectId(),
        orders: [],
        active: '',
        currentLocation: Location(latitude: latitude, longitude: longitude),
        name: '', // Varsayılan değer
      );
    }

    notifyListeners(); // Dinleyicilere güncellemeleri bildir
  }

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
    super.dispose();
  }
}
