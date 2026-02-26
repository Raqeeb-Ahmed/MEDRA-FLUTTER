import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/utills/constant/colors.dart';
import 'package:medra/utills/constant/images.dart';
import '../controller/auth_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_form.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.asset(RImages.appIcon),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "MEDRA",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RColors.primary,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Medical Imaging & Consultation Platform",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: RColors.darkGrey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // LOGIN / SIGNUP SWITCH
                      Obx(() => Container(
                        decoration: BoxDecoration(
                          color: RColors.grey,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: 45,
                        width: 200, // Thori width barha di balance ke liye
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.switchToLogin,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: controller.isLogin.value
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: controller.isLogin.value
                                        ? [BoxShadow(color: Colors.black12, blurRadius: 2)]
                                        : [],
                                  ),
                                  child: Center(child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.switchToSignup,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !controller.isLogin.value
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: !controller.isLogin.value
                                        ? [BoxShadow(color: Colors.black12, blurRadius: 2)]
                                        : [],
                                  ),
                                  child: Center(child: Text("Signup", style: TextStyle(fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 30),

                      // FORMS
                      Obx(() {
                        return controller.isLogin.value
                            ? LoginForm()
                            : SignUpForm();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}