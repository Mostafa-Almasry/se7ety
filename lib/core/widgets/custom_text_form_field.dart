import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.prefixIcon,
    this.hintText,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.name,
    this.textAlign,
    this.validator,
    this.controller,
    this.maxLines,
    this.readOnly,
    this.suffixIconButton,
    this.onTap,
    this.textDirection,
    this.isSearch,
    this.onChanged,
    this.suffixIconHasBg = false,
  });
  final String? hintText;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final Widget? suffixIconButton;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextAlign? textAlign;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int? maxLines;
  final bool? readOnly;
  final void Function()? onTap;
  final TextDirection? textDirection;
  final bool? isSearch;
  final void Function(String)? onChanged;
  final bool? suffixIconHasBg;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObsecure = true;

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      autofocus: false,
      textDirection: widget.textDirection ?? TextDirection.rtl,
      onTap: widget.onTap,
      controller: widget.controller,
      validator: widget.validator,

      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines ?? 1,
      textAlign: widget.textAlign ?? TextAlign.start,
      readOnly: widget.readOnly ?? false,
      obscureText: widget.isPassword ? _isObsecure : false,

      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isObsecure = !_isObsecure;
                    });
                  },
                  icon: Icon(
                    _isObsecure ? Icons.visibility_off : Icons.visibility,
                  ),
                )
                : widget.suffixIcon != null
                ? (widget.suffixIconHasBg == true
                    ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.color1,
                        shape: BoxShape.circle,
                      ),
                      child: widget.suffixIcon,
                    )
                    : widget.suffixIcon)
                : widget.suffixIconButton,

        alignLabelWithHint: true,
      ),
      onChanged: widget.onChanged,
    );
    if (widget.isSearch == true) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: AppColors.grey.withOpacity(.3),
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: textField,
      );
    }
    return textField;
  }
}
