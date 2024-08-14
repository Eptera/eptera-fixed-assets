
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Globals/constant.dart';


class CTextFormField extends StatefulWidget {
  final String? mainText;
  final String? iconPath;
  final IconData? icon;
  final TextInputAction textInputAction;
  final TextInputType? textInputType;
  final Function(String text) onChange;
  final Color headerColor;
  final String? hintText;
  bool? isPasswordForm;
  bool? passwordEyeClosed;
  bool? isUnderlinedForm;
  bool? hasIcon;
  double? iconSize;
  final bool withoutPadding;
  String? initialValue;
  void Function()? changePasswordEyeStatus;
  void Function()? onEditingComplete;
  TextEditingController? controller;
  int? maxLines;
  int? maxLength;
  Function(String text)? validator;
  Color? borderColor;
  bool? autoCorrect;
  bool? enableSuggestions;
  bool? enabled;
  bool? readOnly;
  bool? autoFocus;

  CTextFormField({
    this.mainText,
    this.iconPath,
    this.icon,
    this.headerColor = Colors.black,
    this.hintText,
    this.hasIcon = true,
    required this.textInputAction,
    this.textInputType,
    required this.onChange,
    this.initialValue,
    this.isPasswordForm = false,
    this.withoutPadding = false,
    this.passwordEyeClosed = false,
    this.isUnderlinedForm = false,
    this.iconSize = 30,
    this.changePasswordEyeStatus,
    this.onEditingComplete,
    this.controller,
    this.maxLines,
    this.maxLength,
    this.validator,
    this.borderColor,
    this.autoCorrect = false,
    this.enableSuggestions = false,
    this.enabled = true,
    this.readOnly = false,
    this.autoFocus = false,
  });

  @override
  State<CTextFormField> createState() => _CTextFormFieldState();
}

class _CTextFormFieldState extends State<CTextFormField> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const String passwordClosedEyeIconPath = 'assets/images/closed_eye.svg';
    const String passwordOpenEyeIconPath = 'assets/images/open_eye.svg';
    String errorWidget = '';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //TODO: Error ve Main Text

          Stack(
            alignment: Alignment.centerLeft,
            children: [
              SizedBox(
                height: widget.maxLength != 1 ? null : 44,
                child: TextFormField(
                  autofocus: widget.autoFocus ?? false,
                  readOnly: widget.readOnly ?? false,
                  enabled: widget.enabled ?? true,
                  scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  key: Key(widget.initialValue != null
                      ? widget.initialValue!
                      : widget.controller != null
                          ? widget.controller!.text
                          : ''),
                  textInputAction: widget.textInputAction,
                  keyboardType: widget.textInputType != null ? widget.textInputType! : TextInputType.text,
                  // initialValue: widget.initialValue,
                  maxLength: widget.maxLength ?? 35,
                  obscureText: widget.passwordEyeClosed! ? true : false,
                  obscuringCharacter: "*",
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    widget.onChange(value);
                  },
                  // onEditingComplete: widget.onEditingComplete,
                  validator: (value) {
                    if (widget.validator != null) {
                      return widget.validator!(value!);
                    } else {
                      return null;
                    }
                  },
                  controller: widget.controller,
                  maxLines: widget.maxLines ?? 1,
                  decoration: InputDecoration(
                    suffixIcon: widget.isPasswordForm!
                        ? GestureDetector(
                            onTap: () {
                              widget.changePasswordEyeStatus!();
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                widget.passwordEyeClosed! ? passwordClosedEyeIconPath : passwordOpenEyeIconPath,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          )
                        : null,
                    // suffixIcon: widget.isPasswordForm!
                    //     ? Padding(
                    //         padding: EdgeInsets.only(right: 8),
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             widget.changePasswordEyeStatus!();
                    //           },
                    //           child: SvgPicture.asset(
                    //             widget.passwordEyeClosed! ? passwordClosedEyeIconPath : passwordOpenEyeIconPath,
                    //           ),
                    //         ),
                    //       )
                    //     : null,
                    floatingLabelStyle: k14w400Black(color: Colors.amber),
                    hintText: widget.hintText ?? "",
                    hintStyle: k16w400Black(color: kGrey500),
                    labelStyle: k14w400Black(),
                    errorStyle: k14w400Black(color: kErrorTextColor),
                    counterText: '',
                    focusColor: Colors.black,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(9),
                      ),
                      borderSide: BorderSide(color: kErrorBorderColor, width: 1),
                    ),
                    border: widget.isUnderlinedForm!
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(color: widget.borderColor ?? kBorderColor),
                          )
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(color: widget.borderColor ?? kBorderColor, width: 1),
                          ),
                    focusedBorder: widget.isUnderlinedForm!
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(color: widget.borderColor ?? kBorderColor),
                          )
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(9),
                            ),
                            borderSide: BorderSide(color: widget.borderColor ?? kBorderColor, width: 1),
                          ),
                    contentPadding: EdgeInsets.only(left: widget.hasIcon! ? 40 : 10, top: widget.maxLines != 1 ? 10 : 0),
                  ),
                  autocorrect: widget.autoCorrect!,
                  enableSuggestions: widget.enableSuggestions!,
                ),
              ),
              if (widget.hasIcon!)
                Positioned(
                  left: 10,
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: widget.iconSize,
                        )
                      : (widget.iconPath != null && widget.iconPath!.contains(".svg"))
                          ? SvgPicture.asset(widget.iconPath!)
                          : Image.asset(
                              widget.iconPath!,
                              width: 40,
                              height: 30,
                            ),
                ),
              // if (widget.isPasswordForm!)
              //   Positioned(
              //     right: 14,
              //     top: 14,
              //     child: GestureDetector(
              //       child: SvgPicture.asset(
              //         widget.passwordEyeClosed! ? passwordClosedEyeIconPath : passwordOpenEyeIconPath,
              //         // width: 40,
              //         // height: 30,
              //       ),
              //       onTap: () {
              //         widget.changePasswordEyeStatus!();
              //       },
              //     ),
              //   )
            ],
          ),
        ],
      ),
    );
  }
}
