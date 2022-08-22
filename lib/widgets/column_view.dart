import 'dart:math';

import 'package:flutter/material.dart';

class ColumnView extends StatefulWidget {
  const ColumnView({Key? key, required this.columns, required this.widgets})
      : super(key: key);

  final int columns;
  final List<Widget> widgets;

  @override
  State<ColumnView> createState() => _ColumnViewState();
}

class _ColumnViewState extends State<ColumnView> {
  @override
  Widget build(BuildContext context) {
    var columns = widget.columns;
    var widgets = widget.widgets;

    // Builds a multi-column layout widget
    List<Widget> buildView() {
      List<Expanded> view = [];
      int split = min(widgets.length, columns);
      int subLength = (widgets.length / split).ceil();

      var mainWidgets = Iterable<int>.generate(split).toList().map((index) =>
          widgets.sublist(subLength * index,
              min(subLength * index + subLength, widgets.length)));

      for (var mainWidget in mainWidgets) {
        view.add(Expanded(
            child: Column(
          children: mainWidget,
        )));
      }

      return view;
    }

    // Display the Columns in a Row
    Widget mainRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildView(),
    );

    return mainRow;
  }
}
