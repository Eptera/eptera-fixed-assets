import 'package:flutter/material.dart';
import '../Globals/index.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? kPrimaryColor : Color(0xFFF2F4F7),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              child: Container(
                width: 20,
                height: 24,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0F101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x19101828),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ],
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
