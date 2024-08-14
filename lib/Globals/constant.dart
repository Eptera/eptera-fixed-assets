import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFE04F16);
const kSecondaryColor = Color(0xFFFAC515);
const kBorderColor = Color(0xFFD0D5DD);
const kBorderColor2 = Color(0xFFEAECF0);
const kErrorBorderColor = Color(0xFFFDA29B);
const kErrorTextColor = Color(0xFFF04438);

const kGrey50 = Color(0xFFF9FAFB);
const kGrey500 = Color(0xFF667085);
const kGrey600 = Color(0xFF475467);
const kGrey700 = Color(0xFF344054);
const kGrey900 = Color(0xFF101828);
const kShadowColor = Color(0x0C101828);
const kBackgroundColor = Color.fromARGB(255, 232, 236, 232);
const kWhite = Colors.white;

TextStyle k10w500Black({
  Color? color,
  bool isUnderlineText = false,
}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontStyle: FontStyle.normal,
    fontSize: 10.0,
    decoration: isUnderlineText ? TextDecoration.underline : TextDecoration.none,
  );
}

TextStyle k12w400Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w400,
    fontFamily: "Inter",
    fontSize: 12,
  );
}

TextStyle k12w500Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: "Inter",
    fontSize: 12,
  );
}

TextStyle k12w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 12,
  );
}

TextStyle k14w400Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w400,
    fontFamily: "Inter",
    fontSize: 14,
  );
}

TextStyle k14w500Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: "Inter",
    fontSize: 14,
  );
}

TextStyle k14w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 14,
  );
}

TextStyle k14Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontFamily: "Inter",
    fontSize: 14,
  );
}

TextStyle k16w400Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    fontFamily: "Inter",
  );
}

TextStyle k16w500Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    fontFamily: "Inter",
  );
}

TextStyle k16w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    fontFamily: "Inter",
  );
}

TextStyle k18w400Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w400,
    fontFamily: "Inter",
    fontSize: 18,
  );
}

TextStyle k18w600Black({Color? color}) {
  return TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w600, fontFamily: "Inter", fontStyle: FontStyle.normal, fontSize: 18.0);
}

TextStyle k18w700Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: "Inter",
    fontSize: 18,
  );
}

TextStyle k20w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 20,
  );
}

TextStyle k20w700Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: "Inter",
    fontSize: 20,
  );
}

TextStyle k24w600Black({Color? color}) {
  return TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w600, fontFamily: "Inter", fontStyle: FontStyle.normal, fontSize: 24.0);
}

TextStyle k27w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 27,
  );
}

TextStyle k30w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 30,
  );
}

TextStyle k36w600Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: "Inter",
    fontSize: 36,
  );
}

TextStyle k36w700White({
  Color? color,
  bool isUnderlineText = false,
}) {
  return TextStyle(
    color: color ?? kWhite,
    fontWeight: FontWeight.w700,
    fontSize: 36,
    fontFamily: "Inter",
    decoration: isUnderlineText ? TextDecoration.underline : TextDecoration.none,
  );
}

TextStyle k51w700White({Color? color}) {
  return TextStyle(
    color: color ?? kWhite,
    fontWeight: FontWeight.w700,
    fontFamily: "Inter",
    fontSize: 51,
  );
}

TextStyle k36w400White({Color? color}) {
  return TextStyle(
    color: color ?? kWhite,
    fontWeight: FontWeight.w400,
    fontFamily: "Inter",
    fontSize: 36,
  );
}

TextStyle k17w700Black({Color? color}) {
  return TextStyle(
    color: color ?? Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: "Inter",
    fontSize: 17,
  );
}
