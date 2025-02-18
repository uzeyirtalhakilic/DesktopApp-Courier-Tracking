// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_courier/contexts/web_socket_provider.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';

class MapComponent extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<Courier> couriers;
  final String restaurantName;
  final List<Order> activeOrders;
  final bool createOrder;
  final Function(LatLng) onLocationSelected;

  const MapComponent({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.couriers,
    required this.restaurantName,
    required this.activeOrders,
    required this.createOrder,
    required this.onLocationSelected,
  });

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);

    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.latitude, widget.longitude),
        zoom: 14.0,
        onTap: (tapPosition, latlng) {
          if (widget.createOrder) {
            setState(() {
              selectedLocation = latlng;
            });
            widget.onLocationSelected(latlng);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        // Restoran ve müşteri markerları sabit olduğu için statik bir MarkerLayer kullanabiliriz
        MarkerLayer(
          markers: [
            // Restoran Marker
            Marker(
              point: LatLng(widget.latitude, widget.longitude),
                child: Image.asset(
                'assets/markers/restaurantMarker.png',
                width: 50,
                height: 50,
              ),
            ),
            // Müşteri Marker'ları
            ...widget.activeOrders.map((order) {
              return Marker(
                point: LatLng(
                  order.customerLocation.latitude,
                  order.customerLocation.longitude,
                ),
                child: Image.asset(
                  'assets/markers/customerMarker.png',
                  width: 50,
                  height: 50,
                ),
              );
            }),
            // Seçili Konum Marker'ı
            if (selectedLocation != null && widget.createOrder)
              Marker(
                point: selectedLocation!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
          ],
        ),
        // Kurye Marker'ları dinamik olduğu için StreamBuilder kullanıyoruz
        StreamBuilder<Map<String, Courier>>(
          stream: webSocketProvider.courierStream, // WebSocket üzerinden kurye güncellemelerini dinler
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            
            final courierMarkers = snapshot.data!.entries.map((entry) {
              final courier = entry.value;
              return Marker(
                point: LatLng(
                  courier.currentLocation.latitude,
                  courier.currentLocation.longitude,
                ),
                child: Image.asset(
                  'assets/markers/motorcycleMarker.png',
                  width: 50,
                  height: 50,
                ),
              );
            }).toList();

            return MarkerLayer(
              markers: courierMarkers,
            );
          },
        ),
      ],
    );
  }
}
