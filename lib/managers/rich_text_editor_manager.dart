import 'package:flutter/material.dart';

class RichTextEditorManager extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  RichTextEditorManager(this.map)
      : pattern = RegExp(
            map.keys.map((key) {
              return key;
            }).join('|'),
            multiLine: true);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  static TextStyle newTextStyle = const TextStyle();

  // Builds a TextSpan with the specified formatting options
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<InlineSpan> inlineSpans = [];
    String patternMatched = "";
    String formatText;
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        newTextStyle = map[match[0]] ??
            map[map.keys.firstWhere(
              (e) {
                bool ret = false;
                RegExp(e).allMatches(text).forEach((element) {
                  if (element.group(0) == match[0]) {
                    patternMatched = e;
                    ret = true;

                    return;
                  }
                });
                return ret;
              },
            )]!;

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r';(.*?);') {
          formatText = match[0]!.replaceAll(";", " ");
        } else {
          formatText = match[0]!;
        }
        inlineSpans.add(TextSpan(
          text: formatText,
          style: style!.merge(newTextStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        inlineSpans.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: inlineSpans);
  }
}
