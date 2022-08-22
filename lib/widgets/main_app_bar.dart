import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatefulWidget with PreferredSizeWidget {
  const MainAppBar(
      {Key? key,
      required this.title,
      this.actionButtons = const [],
      this.onBackButtonPressed})
      : super(key: key);

  final String title;
  final List<Widget> actionButtons;
  final Function? onBackButtonPressed;

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _MainAppBarState extends State<MainAppBar> {
  // Builds a MainAppBar widget
  @override
  Widget build(BuildContext context) {
    var title = widget.title;
    var actionButtons = widget.actionButtons;
    var onBackButtonPressed = widget.onBackButtonPressed;

    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      leadingWidth: 50.0,
      actions: [...actionButtons],
      elevation: 0.0,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: Icon(FluentIcons.arrow_left_24_regular,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                if (onBackButtonPressed != null) {
                  onBackButtonPressed();
                } else {
                  Navigator.of(context).pop();
                }
              },
              splashRadius: 20.0,
            )
          : null,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(),
    );
  }
}
