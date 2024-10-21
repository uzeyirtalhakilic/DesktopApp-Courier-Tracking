// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:webview_windows/webview_windows.dart';

class MapComponent extends StatelessWidget {
  final double latitude;
  final double longitude;
  final List<Courier> couriers;
  final String restaurantName;
  final List<Order> activeOrders;
  final WebviewController controller; // WebviewController dışarıdan geliyor

  const MapComponent({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.couriers,
    required this.restaurantName,
    required this.activeOrders,
    required this.controller, // Controller dışarıdan sağlanmalı

  });

  Future<String> generateHtmlContent() async {
    String restaurantIconBase64 = base64Encode(
        (await rootBundle.load('assets/markers/restaurantMarker.png'))
            .buffer
            .asUint8List());
    String courierIconBase64 = base64Encode(
        (await rootBundle.load('assets/markers/motorcycleMarker.png'))
            .buffer
            .asUint8List());
    String customerIconBase64 = base64Encode(
        (await rootBundle.load('assets/markers/customerMarker.png'))
            .buffer
            .asUint8List());

    // İşaretçileri oluştur
    String markers = '''
    var restaurantIcon = L.icon({
      iconUrl: 'data:image/png;base64,$restaurantIconBase64',
      iconSize: [38, 38],
      iconAnchor: [19, 38],
      popupAnchor: [0, -30]
    });

    var courierIcon = L.icon({
      iconUrl: 'data:image/png;base64,$courierIconBase64',
      iconSize: [38, 38],
      iconAnchor: [19, 38],
      popupAnchor: [0, -30]
    });
    var customerIcon = L.icon({
      iconUrl: 'data:image/png;base64,$customerIconBase64',
      iconSize: [38, 38],
      iconAnchor: [19, 38],
      popupAnchor: [0, -30]
    });

    var restaurantMarker = L.marker([$latitude, $longitude], { icon: restaurantIcon }).addTo(map)
      .bindPopup('$restaurantName').openPopup();

    var courierMarkers = {};
    var customerMarkers = {};
  ''';

    // Kuryelerin işaretçilerini oluşturun
    for (var courier in couriers) {
      markers += '''
      courierMarkers['${courier.id.toHexString()}'] = L.marker([${courier.currentLocation.latitude}, ${courier.currentLocation.longitude}], { icon: courierIcon }).addTo(map)
        .bindPopup('${courier.name}');
    ''';
    }

    // Müşterilerin işaretçilerini oluştur
    for (var order in activeOrders) {
      markers += '''
      customerMarkers['${order.id.toHexString()}'] = L.marker([${order.customerLocation.latitude}, ${order.customerLocation.longitude}], { icon: customerIcon }).addTo(map)
        .bindPopup('Müşteri: ${order.customer}');
    ''';
    }

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>OpenStreetMap</title>
        <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
        <style>
          body, html {
            margin: 0;
            padding: 0;
            overflow: hidden; /* Sayfa genelinde scroll'u kaldırır */
          }

        #map {
          height: 100vh;
          width: 100vw;
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
        }
</style>

    </head>
    <body>
        <div id="map"></div>
        <script>
            var map = L.map('map').setView([$latitude, $longitude], 14);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);
            
            $markers

            function updateCourierMarker(courierId, latitude, longitude) {
              if (courierMarkers[courierId]) {
                courierMarkers[courierId].setLatLng([latitude, longitude]);
              }
            }

            // WebSocket bağlantısı ile kurye konum güncellemelerini dinleyin
            var ws = new WebSocket('ws://localhost:3000');
            ws.onmessage = function(event) {
              var data = JSON.parse(event.data);
              if (data.courierObjectId && data.latitude && data.longitude) {
                updateCourierMarker(data.courierObjectId, data.latitude, data.longitude);
              }
            };
        </script>
    </body>
    </html>
  ''';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: generateHtmlContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final dataUrl = Uri.dataFromString(
            snapshot.data!,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ).toString();

          // Webview'i yükle
          controller.loadUrl(dataUrl);
          return Webview(controller);
        
        }
      },
    );
  }
}
