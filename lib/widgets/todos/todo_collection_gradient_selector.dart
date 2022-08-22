import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoCollectionGradientSelector extends StatefulWidget {
  const TodoCollectionGradientSelector({Key? key, required this.onGradientChanged, required this.selectedGradientIndex})
      : super(key: key);

  final Function onGradientChanged;
  final int selectedGradientIndex;

  @override
  State<TodoCollectionGradientSelector> createState() => _TodoCollectionGradientSelectorState();
}

class _TodoCollectionGradientSelectorState extends State<TodoCollectionGradientSelector> {
  late int gradientSelectedIndex = widget.selectedGradientIndex;

  @override
  Widget build(BuildContext context) {
    var onGradientChanged = widget.onGradientChanged;

    // Updates selected gradient
    void gradientSelected(int index) {
      setState(() {
        gradientSelectedIndex = index;
      });
    }

    // Builds a list of LinearGradients
    List<Widget> buildGradients() {
      var gradientList = AppStyles.linearGradients.asMap().map(
        (index, gradient) {
          var gradientBorderWidth = AppStyles.gradientSelectorStartWidth;

          if (gradientSelectedIndex == -1) {
            gradientBorderWidth = AppStyles.gradientSelectorStartWidth;
          }

          if (index == gradientSelectedIndex) {
            gradientBorderWidth = AppStyles.gradientSelectorEndWidth;
          }
          return MapEntry(
            index,
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: AppStyles.gradientSelectorStartWidth, end: gradientBorderWidth),
              duration: const Duration(milliseconds: 50),
              builder: (context, value, _) {
                return GestureDetector(
                  onTap: () {
                    gradientSelected(index);
                    onGradientChanged(AppStyles.linearGradients[gradientSelectedIndex]);
                  },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 148, 114), width: value.round().toDouble())),
                  ),
                );
              },
            ),
          );
        },
      );

      return gradientList.values.toList();
    }

    return SizedBox(
      height: 50.0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: buildGradients(),
      ),
    );
  }
}
