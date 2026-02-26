import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/consultation/screen/consultations_screen.dart';
import 'package:medra/utills/constant/colors.dart';

import 'modules/settings/screen/settings_screen.dart';
import 'modules/studies/screen/studies_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controller.screens[controller.selectedIndex.value]),

      /// Navigation Menu
      bottomNavigationBar: Obx(
            () => NavigationBar(
          elevation: 0,
          backgroundColor: RColors.light,
          indicatorColor: RColors.light.withOpacity(1.0),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (value) => controller.selectedIndex.value = value,
          // Real-time role based destinations
          destinations: controller.navDestinations,
        ),
      ),
    );
  }
}


// Navigation Getx Controller
class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final local = GetStorage();

  RxInt selectedIndex = 0.obs;

    var screens = <Widget>[].obs;
    var navDestinations = <NavigationDestination>[].obs;

    @override
  void onInit() {
    super.onInit();
    _loadMenuBasedOnRole();
  }

  void _loadMenuBasedOnRole() {
      String role = local.read('role')?? "patient";

      if(role == "doctor"){
        screens.assignAll([
          ConsultationsScreen(),
          StudiesScreen(),
          SettingsScreen()
        ]);

        navDestinations.assignAll([
          const NavigationDestination(icon: Icon(Icons.date_range_outlined), label: 'Consult'),
          const NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Studies'),
          const NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ]);
      } else {
        screens.assignAll([
          StudiesScreen(),
          ConsultationsScreen(),
          SettingsScreen(),
        ]);
        navDestinations.assignAll([
          const NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Studies'),
          const NavigationDestination(icon: Icon(Icons.date_range_outlined), label: 'Consult'),
          const NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ]);
      }
  }
}