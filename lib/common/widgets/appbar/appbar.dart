
import 'package:flutter/material.dart';

import '../../../modules/authentication/controller/auth_controller.dart';

class RAppBar extends StatelessWidget implements PreferredSizeWidget {
   RAppBar({
    super.key,
    required this.authcontroller,
  });

   final AuthController authcontroller;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEDRA',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            authcontroller.currentusername,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
              onTap: authcontroller.logout,
              child: const Icon(Icons.logout, color: Colors.black)),
        ),
      ],
    );
  }


}