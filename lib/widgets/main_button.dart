import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class MainButton extends StatefulWidget {
  const MainButton(
      {Key? key,
      required this.text,
      this.width = 0.0,
      this.height = 0.0,
      this.margin = const EdgeInsets.all(10.0),
      this.padding = const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      required this.onPressed})
      : super(key: key);

  final String text;
  final double width;
  final double height;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Function onPressed;

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  // Builds a MainButton widget
  @override
  Widget build(BuildContext context) {
    var text = widget.text;
    var width = widget.width;
    var height = widget.height;
    var margin = widget.margin;
    var padding = widget.padding;
    var onPressed = widget.onPressed;

    return Container(
      width: (width != 0.0) ? width : null,
      height: (height != 0.0) ? height : null,
      margin: margin,
      // padding: padding,
      decoration: BoxDecoration(
          gradient: AppStyles.linearGradients[0],
          borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius),
          onTap: () {
            onPressed();
          },
          splashColor: AppStyles.splashColor,
          child: Padding(
            padding: padding,
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }
}
