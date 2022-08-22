import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/users/logged_in_session.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class LoggedInSessionListViewTile extends StatefulWidget {
  const LoggedInSessionListViewTile({Key? key, required this.loggedInSession}) : super(key: key);

  final LoggedInSession loggedInSession;

  @override
  State<LoggedInSessionListViewTile> createState() => _LoggedInSessionListViewTileState();
}

class _LoggedInSessionListViewTileState extends State<LoggedInSessionListViewTile> {
  bool animate = false;
  static bool start = true;

  @override
  void initState() {
    super.initState();
    // Wait for the animation to finish
    start
        ? Future.delayed(Duration(milliseconds: AppStyles.animationDuration.inMilliseconds)).then((value) {
            setState(() {
              animate = true;
              start = false;
            });
          })
        : animate = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loggedInSession = widget.loggedInSession;

    return AnimatedOpacity(
      opacity: animate ? 1.0 : 0.0,
      duration: AppStyles.animationDuration,
      child: Card(
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListTile(
                title: Text("Device: ${loggedInSession.deviceOS}", style: Theme.of(context).textTheme.headline1),
                subtitle: Text("Last Logged In: ${AppStyles().getFormattedDateTimeString(loggedInSession.loggedIn)}",
                    style: Theme.of(context).textTheme.headline2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
