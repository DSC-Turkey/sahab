import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sahab/extensions/global_colors.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final TextStyle style;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final TextAlign textAlign;
  final Widget prefix;

  const CustomTextField(
      {Key key,
      this.title,
      this.description,
      this.controller,
      this.onChanged,
      this.obscureText,
      this.keyboardType,
      this.enabled,
      this.style,
      this.maxLength,
      this.inputFormatters,
      this.textInputAction,
      this.textAlign,
      this.prefix})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.title != null
              ? Text(
                  widget.title,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 15),
                )
              : Container(),
          widget.description != null
              ? Text(
                  widget.description,
                  style: GoogleFonts.montserrat(fontSize: 12),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: widget.obscureText ?? false,
            cursorColor: GlobalColors.appColor,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            controller: widget.controller,
            minLines: 1,
            textInputAction: widget.textInputAction,
            maxLines: widget.keyboardType == TextInputType.multiline ? null : 1,
            onChanged: widget.onChanged,
            textAlign: widget.textAlign ?? TextAlign.start,
            inputFormatters: widget.inputFormatters,
            style: widget.style,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixStyle: TextStyle(
                    color: GlobalColors.appColor,
                    backgroundColor: GlobalColors.appColor,
                    decorationColor: GlobalColors.appColor),
                fillColor: Color(0xfff3f3f4),
                prefixIcon: widget.prefix,
                counterText:
                    widget.maxLength != null && widget.controller != null
                        ? '${widget.controller.text.length}/${widget.maxLength}'
                        : null,
                filled: true),
            keyboardType: widget.keyboardType ?? TextInputType.text,
          )
        ],
      ),
    );
  }
}
