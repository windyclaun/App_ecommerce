import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projectakhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectakhir_mobile/pages/base_page.dart';

// Meminta izin lokasi secara runtime
// Future<void> _requestLocationPermission() async {
//   PermissionStatus status = await Permission.location.request();
//   if (status.isGranted) {
//     print('Location permission granted');
//   } else if (status.isDenied) {
//     print('Location permission denied');
//     openAppSettings(); 
//   } else if (status.isPermanentlyDenied) {
//     print('Location permission permanently denied');
//     openAppSettings(); 
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Meminta izin notifikasi
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  
  // Inisialisasi layanan notifikasi
  await NotificationService.init();


  // Mengambil data token, username, password, dan role dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final username = prefs.getString('username');
  final password = prefs.getString('password');
  final role = prefs.getString('role');
  
  log('Token dari main: $token');
  log('Username dari main: $username');
  log('Password dari main: $password');
  log('Role dari main: $role');

  // Menjalankan aplikasi dengan parameter yang diambil
  runApp(MyApp(token: token, username: username, password: password, role: role));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? username;
  final String? role;
  final String? password;

  const MyApp({super.key, this.token, this.username, this.role, this.password});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: BasePage(
        token: token, 
        username: username, 
        password: password, 
        role: role
      ),
    );
  }
}
