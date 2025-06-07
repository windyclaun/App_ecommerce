import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:projectakhir_mobile/controllers/location_controller.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());

    return Scaffold(
      appBar: AppBar(title: const Text('Select Delivery Location')),
      body: Obx(() {
        if (!locationController.isLocationLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    locationController.userLatitude.value,
                    locationController.userLongitude.value,
                  ),
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    locationController.sendLatitude.value = point.latitude;
                    locationController.sendLongitude.value = point.longitude;
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      // User marker (green)
                      Marker(
                        point: LatLng(
                          locationController.userLatitude.value,
                          locationController.userLongitude.value,
                        ),
                        width: 80,
                        height: 80,
                        rotate: true,
                        child: Transform.rotate(
                          angle: locationController.userHeading.value * (3.141592653589793 / 180),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.green,
                            size: 24.0,
                          ),
                        ),
                      ),
                      // Delivery location marker (red)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(
                          locationController.sendLatitude.value,
                          locationController.sendLongitude.value,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24.0,
                        ),
                      ),
                      // Store marker (blue)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(
                          locationController.storeLatitude.value,
                          locationController.storeLongitude.value,
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.blue,
                          size: 24.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Delivery Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Balik ke halaman sebelumnya (cart)
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
