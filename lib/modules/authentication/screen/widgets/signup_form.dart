import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/common/widgets/button/elevated_button.dart';

import '../../controller/auth_controller.dart';

class SignUpForm extends StatelessWidget {
   SignUpForm({
    super.key,
  });

  final AuthController controller = AuthController.instance;
  final TextEditingController usernameController = .new();
  final TextEditingController emailController = .new();
  final TextEditingController passwordController = .new();
  final TextEditingController specializationController = .new();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Username"),
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: "Enter Username",
            border: OutlineInputBorder(),
          ),
        ),
        // SizedBox(height: 10),
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
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter Password",
            border: OutlineInputBorder(),
          ),
        ),
        // SizedBox(height: 15),
        Text("Role"),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Obx(() => Radio(
                  value: "patient",
                  groupValue: controller.selectedRole.value,
                  onChanged: (value) {
                    controller.selectedRole.value = value!;
                  },
                )),
                Text("Patient"),
              ],
            ),


            // DOCTOR RADIO
            Row(
              children: [
                Obx(() => Radio(
                  value: "doctor",
                  groupValue: controller.selectedRole.value,
                  onChanged: (value) {
                    controller.selectedRole.value = value!;
                  },
                )),
                Text("Doctor"),
              ],
            ),

            // SPECIALIZATION (ONLY FOR DOCTOR)
            Obx(() => controller.selectedRole.value == "doctor"
                ? Padding(
              padding: const EdgeInsets.only(top: 5),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Specialization"),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: specializationController,
                    decoration: InputDecoration(
                      hintText: "Specialization",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox()),
          ],
        ),


        SizedBox(height: 10,),
        SizedBox(
          width: double.infinity,
          height: 50,
          child:Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
              controller.registeruser(
                usernameController.text.trim(),
                emailController.text.trim(),
                passwordController.text,
                controller.selectedRole.value,
                specializationController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white
            ),
            child: controller.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Create Account", style: TextStyle(fontSize: 18)),
          )),
        ),
      ],
    );
  }
}

