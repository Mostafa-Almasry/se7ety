import 'package:flutter/material.dart';
import 'package:se7ety/core/constants/specialisation.dart';

const Color skyBlue = Color(0xff71b4fb);
const Color lightSkyBlue = Color(0xff7fbcfb);

const Color orange = Color(0xfffa8c73);
const Color lightOrange = Color(0xfffa9881);

const Color purple = Color(0xff8873f4);
const Color lightPurple = Color(0xff9489f4);

const Color green = Color(0xff4cd1bc);
const Color lightGreen = Color(0xff5ed6c3);

const Color red = Color(0xFFF0574C);
const Color lightRed = Color(0xFFFC7A71);

const Color yellow = Color(0xFFFCA728);
const Color lightYellow = Color(0xFFFCB54B);

const Color blue = Color(0xFF565BFB);
const Color lightBlue = Color(0xFF787DFB);

const Color pink = Color(0xFFFA32E9);
const Color lightPink = Color(0xFFFC52EE);

const Color dGreen = Color(0xFF34F323);
const Color lightDGreen = Color(0xFF70FD63);

const Color dPink = Color(0xFFF32368);
const Color lightDpink = Color(0xFFF6548A);

class CardModel {
  String specialisation;
  Color cardBgColor;
  Color cardLightColor;
  CardModel(this.specialisation, this.cardBgColor, this.cardLightColor);
}

List<CardModel> cards = [
  CardModel(specialisation[0], skyBlue, lightSkyBlue),
  CardModel(specialisation[4], green, lightGreen),
  CardModel(specialisation[2], yellow, lightYellow),
  CardModel(specialisation[3], blue, lightBlue),
  CardModel(specialisation[1], red, lightRed),
  CardModel(specialisation[5], pink, lightPink),
  CardModel(specialisation[6], orange, lightOrange),
  CardModel(specialisation[7], purple, lightPurple),
  CardModel(specialisation[8], dGreen, lightDGreen),
  CardModel(specialisation[9], dPink, lightDpink),
];
