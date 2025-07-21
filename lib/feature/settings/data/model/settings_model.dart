import 'package:flutter/material.dart';

class SettingsModel {
  final String? title;
  final IconData? icon;
  final Widget? view;
  final Widget? trailing;
  final Widget? leading;
  final void Function()? onTap;

  SettingsModel(
      {this.trailing,
      this.view,
      this.title,
      this.icon,
      this.leading,
      this.onTap});
}

// class ProfileSettingsModel {
  
// }
