import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medra/common/widgets/appbar/appbar.dart';
import 'package:medra/modules/authentication/controller/auth_controller.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());
  final AuthController authcontroller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RAppBar(authcontroller: authcontroller),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _profileCard(),
            const SizedBox(height: 16),
            _passwordCard(),
            const SizedBox(height: 16),
            _accountInfoCard(),
          ],
        ),
      ),
    );
  }

  // ===== Profile Card =====
  Widget _profileCard() {
    return _card(
      title: "Profile",
      icon: Icons.person_outline,
      child: Column(
        children: [
          _field("Username", authcontroller.usernameController),
          _field("Email", authcontroller.emailController),
          const SizedBox(height: 12),
          _button("Update", Icons.edit, authcontroller.handleUpdateProfile),
        ],
      ),
    );
  }

  // ===== Change Password Card =====
  Widget _passwordCard() {
    return _card(
      title: "Change Password",
      icon: Icons.lock_outline,
      child: Column(
        children: [

          _passwordField(
            "Old Password",
               authcontroller.oldPasswordController
          ),

          _passwordField(
            "New Password",authcontroller.newPasswordController,
          ),
          _passwordField(
            "Confirm New Password",authcontroller.confirmPasswordController,
          ),
          const SizedBox(height: 12),
          _button(
            "Update Password",
            Icons.lock,
            authcontroller.handleChangePassword,
          ),
        ],
      ),
    );
  }

  // ===== Account Info Card =====
  Widget _accountInfoCard() {
    return _card(
      title: "Account Information",
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _infoRow("Username", "Dr Raqeeb"),
          Divider(),
          _infoRow("Contact Information", "ahmedraqeeb@gmail.com"),
          Divider(),
          _infoRow("Type", "Doctor"),
          Divider(),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Icon(Icons.qr_code, size: 80),
            ),
          )
        ],
      ),
    );
  }

  // ===== Reusable Widgets =====
  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          // readOnly: true,
          decoration: _inputDecoration(hint: ''),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _passwordField(String label,TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          obscureText: true,
          // onChanged: onChanged,
          decoration: _inputDecoration(hint: "********"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _button(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }

  static InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

}

// ===== Info Row Widget =====
class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
