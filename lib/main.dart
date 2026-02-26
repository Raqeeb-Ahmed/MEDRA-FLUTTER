import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/authentication/screen/login_screen.dart';
import 'package:medra/navigation_menu.dart';

import 'modules/authentication/controller/auth_controller.dart';
import 'modules/consultation/controller/consultation_controller.dart';
import 'modules/dicom_viewer/screen/dicom_viewer_screen.dart';
import 'modules/studies/screen/studies_screen.dart';

void main() async{
  Get.put(AuthController());
  await GetStorage.init();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final box = GetStorage();
  late String? token = box.read('token');

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget initialScreen = (token != null) ? const NavigationMenu() :  LoginScreen();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: initialScreen,
    );

  }

}

