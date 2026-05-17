import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medra/modules/authentication/screen/login_screen.dart';
import 'package:medra/modules/consultation/controller/consultation_controller.dart';
import 'package:medra/modules/dicom_edit/controller/dicom_edit_controller.dart';
import 'package:medra/modules/studies/controller/studies_controller.dart';
import 'package:medra/modules/studies/screen/studies_screen.dart';
import 'package:medra/navigation_menu.dart';

import '../../../data/services/api_service.dart';
import '../../../utills/snackbar/app_snackbar.dart';
import '../model/user_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // final StudiesController _controller = Get.put(StudiesController());
  // final ConsultationController _consultcontroller = Get.put(ConsultationController());
  // Get Storage
  final localstorage = GetStorage();

  // true = Login, false = Signup
  RxBool isLogin = true.obs;
  RxString selectedRole ="patient".obs;
  late var currentusername = '';

  //Api
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;


  // Profile TextFields
  TextEditingController usernameController = .new();
  TextEditingController emailController = .new();

  // Password TextFields
  TextEditingController oldPasswordController = .new();
  TextEditingController newPasswordController = .new();
  TextEditingController confirmPasswordController = .new();

  

  //switchToLogin
  void switchToLogin() {
    isLogin.value = true;
  }
  // switchToSignup
  void switchToSignup() {
    isLogin.value = false;
  }


  // 1 Register User
  Future<void> registeruser(String name, String email, String pass, String role, String spec) async {
    isLoading.value = true;

    UserModel user = UserModel(
      username: name,
      email: email,
      password: pass,
      role: role,
      specialization: spec,
    );

    try {
      var response = await _apiService.signupUser(user);

      // 1.Save user_id in Local Storage
      var userId = response.data['user_id'].toString();
      await localstorage.write('user_id', userId);

      // 2.Save username in Local Storage
      var username = response.data['username'].toString();
      await localstorage.write('username', username);
      currentusername =localstorage.read('username').toString();

      // 3.Save role in Local Storage
      var role = response.data['role'];
      await localstorage.write('role', role);

      ///SnackBar
      AppSnackbar.success(response.data['message']);

      Get.offAll(() => LoginScreen());
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  // 2 Login User
  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please Enter Username and password");
      return;
    }

    isLoading.value = true;
    try {
      var response = await _apiService.loginUser(username, password);

      // 1.Save TOken in Local Storage
      String token = response.data['access_token'];
      await localstorage.write('token', token);

      // 2.Save user_id in Local Storage
        var userId = response.data['user_id'].toString();
      await localstorage.write('user_id', userId);


      // 3.Save username in Local Storage
      var user = response.data['username'].toString();
      await localstorage.write('username', user);
      currentusername =localstorage.read('username').toString();

      var role = response.data['role'];
      await localstorage.write('role', role);

      // print("Token: ${localstorage.read('token')}");
      // print("User ID: ${localstorage.read('user_id')}");

      AppSnackbar.success( "${currentusername}");

      Get.delete<NavigationController>(force: true);
      Get.offAll(() => const NavigationMenu());

    } catch (e) {
      AppSnackbar.error( e.toString());
    } finally {
      isLoading.value = false;
    }
  }




  // 3 Profile Update
  Future<void> handleUpdateProfile() async {
    if (usernameController.text.isEmpty || emailController.text.isEmpty) {
      AppSnackbar.error("Both Fields must be filled!");
      return;
    }

    isLoading.value = true;
    bool success = await _apiService.updateProfile(
      token: localstorage.read('token'),
      userId: localstorage.read('user_id'),
      username: usernameController.text,
      email: emailController.text,
    );
    isLoading.value = false;

    if (success) {
      AppSnackbar.success("Profile update successfully!");
    } else {

      AppSnackbar.error("Failed to Update");
    }
  }

  // 4 Password Changed
  Future<void> handleChangePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords not matched");
      return;
    }

    isLoading.value = true;
    bool success = await _apiService.changePassword(
      token: localstorage.read('token'),
      userId: localstorage.read('user_id'),
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
    );
    isLoading.value = false;

    if (success) {
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      AppSnackbar.success("Password changed successfully");
    }
  }


  @override
  void onClose() {
    super.onClose();
  }


  // 4. Logout function (
  void logout() {
    // localstorage.erase();
    localstorage.remove('token');
    localstorage.remove('user_id');
    localstorage.remove('username');
    localstorage.remove('role');
    // // _controller.studies.clear();

    // _consultcontroller.studies.clear();
    // _consultcontroller.doctors.clear();
    // Get.deleteAll(force: true);

    Get.delete<StudiesController>();
    Get.delete<ConsultationController>();
    Get.delete<DicomEditController>();

    Get.offAll(() => LoginScreen());
  }


}
