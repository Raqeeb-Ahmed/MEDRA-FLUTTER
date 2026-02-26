import 'package:get/get.dart';

import '../../../utills/snackbar/app_snackbar.dart';

class SettingsController extends GetxController {
  var username = 'Raqeeb Ahmed'.obs;
  var email = 'ahmedraqeeb26@gmail.com'.obs;

  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  void updateProfile() {
   AppSnackbar.success("Profile updated");
  }

  void updatePassword() {
    if (newPassword.value != confirmPassword.value) {
     AppSnackbar.error("Passwords do not match");
      return;
    }
    AppSnackbar.success("Password updated");
  }
}
