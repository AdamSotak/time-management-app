import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class MainFloatingActionButton extends StatefulWidget {
  const MainFloatingActionButton(
      {Key? key, required this.icon, required this.onPressed, this.scale = 1.0})
      : super(key: key);

  final IconData icon;
  final Function onPressed;
  final double scale;

  @override
  State<MainFloatingActionButton> createState() =>
      _MainFloatingActionButtonState();
}

class _MainFloatingActionButtonState extends State<MainFloatingActionButton> {
  // Builds a MainFloatingActionButton widget
  @override
  Widget build(BuildContext context) {
    var icon = widget.icon;
    var onPressed = widget.onPressed;
    var scale = widget.scale;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: scale * 55.0,
      height: scale * 55.0,
      decoration: BoxDecoration(
          gradient: AppStyles.linearGradients[0],
          borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius),
          boxShadow: [AppStyles.boxShadow]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius),
          onTap: () {
            onPressed();
          },
          splashColor: AppStyles.splashColor,
          child: Visibility(
            visible: (scale == 1.0) ? true : false,
            child: Center(
              child: Icon(icon, color: Colors.white,),
            ),
          ),
        ),
      ),
    );
  }
}
