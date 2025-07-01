import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/app_colors.dart';

TextStyle getHeadlineStyle({
  double fontSize = 24,
  fontWeight = FontWeight.bold,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.color1,
  );
}

TextStyle getTitleStyle({
  double fontSize = 18,
  fontWeight = FontWeight.bold,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.color1,
  );
}

TextStyle getBodyStyle({
  double fontSize = 16,
  fontWeight = FontWeight.bold,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.black,
  );
}

TextStyle getSmallStyle({
  double fontSize = 14,
  fontWeight = FontWeight.bold,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColors.black,
  );
}
