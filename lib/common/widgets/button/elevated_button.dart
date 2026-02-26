import 'package:flutter/material.dart';
import 'package:medra/utills/constant/colors.dart';
import 'package:medra/utills/helpers/device_helpers.dart';

class RElevatedButton extends StatelessWidget {
  const RElevatedButton({
    super.key, required this.onPressed, required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: RDeviceHelper.getScreenWidth(context),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: RColors.primary,foregroundColor: RColors.white),
        onPressed:onPressed,
        child: child,
      ),
    );
  }
}
