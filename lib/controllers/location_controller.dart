import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationController extends GetxController {
  var userLatitude = (-7.0).obs; // Observable user latitude
  var userLongitude = (11.0).obs; // Observable user longitude
  var sendLatitude = (-7.0).obs; // Observable latitude for the red marker
  var sendLongitude = (11.0).obs; // Observable longitude for the red marker
  var storeLatitude = (-7.78294).obs; // Observable latitude for the blue marker
  var storeLongitude =
      (110.408).obs; // Observable longitude for the blue marker

  var userHeading = 0.0.obs; // Observable heading
  var isLocationLoaded = false.obs; // Loading state

  final Location _location = Location();

  @override
  void onInit() {
    super.onInit();
    _getUserLocation();
    _startCompass();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          // snackbar error
          Get.snackbar('Error', 'Location service is disabled',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
          return;
        }
      }

      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // snackbar error
          Get.snackbar('Error', 'Location permission is denied',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
          return;
        }
      }

      final currentLocation = await _location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        userLatitude.value = currentLocation.latitude!;
        userLongitude.value = currentLocation.longitude!;
        sendLatitude.value = currentLocation.latitude!;
        sendLongitude.value = currentLocation.longitude!;
        isLocationLoaded.value = true;
      } else {
        Get.snackbar('Error', 'Unable to get current location',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  void _startCompass() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        userHeading.value = event.heading!;
      }
    });
  }

  void stopCompass() {
    FlutterCompass.events?.listen((event) {}).cancel();
  }

  double calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  double get distanceStoreToSend {
    return calculateDistanceInKm(
      storeLatitude.value,
      storeLongitude.value,
      sendLatitude.value,
      sendLongitude.value,
    );
  }
}
