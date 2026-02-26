import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/button/elevated_button.dart';
import '../../controller/auth_controller.dart';

class LoginForm extends StatelessWidget {
  LoginForm({
    super.key,
  });

  final AuthController controller = AuthController.instance;

  final TextEditingController emailController = .new();
  final TextEditingController passController = .new();


  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email"),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Enter Email",

            border: OutlineInputBorder(),
          ),
        ),
        // SizedBox(height: 10),
        Text("Password"),
        TextFormField(
          controller: passController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter Password",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
              controller.login(
                  emailController.text.trim(),
                  passController.text
              );
            },
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Sign In"),
          )),
        ),
      ],
    );
  }
}

