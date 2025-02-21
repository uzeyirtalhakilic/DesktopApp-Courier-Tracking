// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_courier/contexts/web_socket_provider.dart';
import 'package:flutter_courier/models/courier.dart';
import 'package:flutter_courier/models/order.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final String styleUrl =
      "https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}{r}.png";
  final String apiKey = "7c199992-0578-4a72-9604-df1cb1c77f5d"; // Replace with your own API key

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
      nonRotatedChildren: [
        RichAttributionWidget(attributions: [
          TextSourceAttribution("Stadia Maps",
              onTap: () => launchUrl(Uri.parse("https://stadiamaps.com/")),
              prependCopyright: true),
          TextSourceAttribution("OpenMapTiles",
              onTap: () => launchUrl(Uri.parse("https://openmaptiles.org/")),
              prependCopyright: true),
          TextSourceAttribution("OpenStreetMap",
              onTap: () => launchUrl(Uri.parse("https://www.openstreetmap.org/copyright")),
              prependCopyright: true),
        ])
      ],
      children: [
        TileLayer(
          urlTemplate: "$styleUrl?api_key=$apiKey",
          additionalOptions: {
            "api_key": apiKey,
          },
          maxZoom: 20,
          maxNativeZoom: 20,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(widget.latitude, widget.longitude),
              child: const Icon(
                Icons.store,
                color: Colors.orange,
                size: 40,
              ),
            ),
            ...widget.activeOrders.map((order) {
              return Marker(
                point: LatLng(
                  order.customerLocation.latitude,
                  order.customerLocation.longitude,
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.red,
                  size: 35,
                ),
              );
            }),
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
        StreamBuilder<Map<String, Courier>>(
          stream: webSocketProvider.courierStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final courierMarkers = snapshot.data!.entries.map((entry) {
              final courier = entry.value;
              return Marker(
                point: LatLng(
                  courier.currentLocation.latitude,
                  courier.currentLocation.longitude,
                ),
                child: const Icon(
                  Icons.motorcycle,
                  color: Colors.black,
                  size: 35,
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
