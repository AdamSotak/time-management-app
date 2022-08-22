import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class NoDataTile extends StatefulWidget {
  const NoDataTile({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<NoDataTile> createState() => _NoDataTileState();
}

class _NoDataTileState extends State<NoDataTile> {
  // Builds a NoDataTile widget
  @override
  Widget build(BuildContext context) {
    var text = widget.text;
    return TweenAnimationBuilder<double>(
      duration: AppStyles.animationDuration,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.blur_on,
                size: 200.0,
                color: (Theme.of(context).iconTheme.color == Colors.black)
                    ? Colors.grey
                    : Colors.white,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 100.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
