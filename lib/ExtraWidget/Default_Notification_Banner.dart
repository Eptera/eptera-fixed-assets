import 'package:flutter/material.dart';
import '../Globals/index.dart';

class DefaultNotificationBanner {
  final String iconPath;
  final String text;
  final String? subText;
  final Color color;
  final BuildContext context;
  final int? durationSeconds;
  final FlushbarPosition? flushbarPosition;

  DefaultNotificationBanner({required this.iconPath, required this.text, this.subText, required this.color, required this.context, this.durationSeconds, this.flushbarPosition});

  Flushbar show() {
    Flushbar flushbar = Flushbar(
      animationDuration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: flushbarPosition == null ? FlushbarPosition.BOTTOM : flushbarPosition!,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderColor: kBorderColor2,
      onTap: (flushbar) => flushbar.dismiss(),
      messageText: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(iconPath),
            SizedBox(height: 16),
            Text(
              text,
              style: k14w600Black(color: kGrey900),
            ),
            SizedBox(height: 4),
            Text(subText ?? "", style: k14w400Black(color: kGrey600)),
          ],
        ),
      ),
      duration: Duration(seconds: durationSeconds == null ? 3 : durationSeconds!),
      backgroundColor: color,
      boxShadows: [
        BoxShadow(
          color: Color(0x07101828),
          blurRadius: 6,
          offset: Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Color(0x14101828),
          blurRadius: 16,
          offset: Offset(0, 12),
          spreadRadius: -4,
        ),
      ],
    )..show(context);
    return flushbar;
  }
}
