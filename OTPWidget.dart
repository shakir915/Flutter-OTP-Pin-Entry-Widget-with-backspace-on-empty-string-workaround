import 'package:flutter/material.dart';

import '../global.dart';

class OTPWidget extends StatefulWidget {
  final int cellCount;
  final int textBoxFlex;
  final int spacingFlex;
  final double verticalPadding;
  final ValueChanged<String>? onChanged;

  const OTPWidget({this.cellCount = 6,this.textBoxFlex=10,this.spacingFlex=1,this.verticalPadding=12, this.onChanged, Key? key}) : super(key: key);

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  static const borderGrey = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(width: .5, color: Color(0xff949494)),
  );

  final String hiddenSpace = "\u2066";
  String fullText = "";

  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;
  late List<String> texts;
  late List<String> prevTexts;

  @override
  void initState() {
    textControllers = List.empty(growable: true);
    focusNodes = List.empty(growable: true);
    texts = List.empty(growable: true);
    prevTexts = List.empty(growable: true);
    for (int i = 0; i < widget.cellCount; i++) {
      var tec = TextEditingController();
      tec.text = hiddenSpace;
      tec.addListener(() {
        if (tec.selection.extentOffset == 0 && tec.selection.baseOffset == 0) {
          tec.selection = TextSelection.fromPosition(
              TextPosition(offset: textControllers[i].text.length));
        }
      });
      textControllers.add(tec);
      focusNodes.add(FocusNode()..addListener(doOnChange));
      texts.add("");
      prevTexts.add("");
    }
    doOnChange();

    super.initState();
  }

  @override
  void dispose() {
    textControllers.forEach((t) => t.dispose());
    focusNodes.forEach((t) => t.dispose());
    super.dispose();
  }

  doOnChange() {
    fullText = "";
    for (int i = 0; i < widget.cellCount; i++) {
      textControllers[i].text = hiddenSpace + texts[i];
      textControllers[i].selection = TextSelection.fromPosition(
          TextPosition(offset: textControllers[i].text.length));
      prevTexts[i] = texts[i];
      fullText += texts[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < widget.cellCount; i++) ...[
          Expanded(
              flex: widget.textBoxFlex,
              child: TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: textControllers[i],
                focusNode: focusNodes[i],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
                  border: borderGrey,
                  enabledBorder: borderGrey,
                  disabledBorder: borderGrey,
                  errorBorder: borderGrey,
                  focusedBorder: borderGrey,
                  focusedErrorBorder: borderGrey,
                ),
                onChanged: (ss) {
                  if (ss.length >= 2) {
                    var s = ss.replaceAll(hiddenSpace, "");
                    if (s.length > 1) {
                      s = s.replaceFirst(prevTexts[i], "");
                    }
                    texts[i] = s[s.length - 1];
                    if (i == widget.cellCount - 1) {
                      focusNodes[i].unfocus();
                    } else {
                      FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                    }
                  } else {
                    texts[i] = "";
                    if (i == 0) {
                    } else {
                      FocusScope.of(context).requestFocus(focusNodes[i - 1]);
                    }
                  }
                  doOnChange();
                  widget.onChanged?.call(fullText);
                  setState(() {});
                },
                onEditingComplete: null,
                onFieldSubmitted: null,
              )),
          Expanded(flex: i == widget.cellCount - 1 ? 0 : widget.spacingFlex, child: Container())
        ]
      ],
    );
  }
}
