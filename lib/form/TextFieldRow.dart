import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final bool isInt;
  final bool isnum;
  final dynamic? initialValue;
  final Function(dynamic)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isPercentage;
  final Map? props;
  final double? width;

  TextFieldRow(
      {Key? key,
      required this.label,
      this.initialValue,
      this.onChanged,
      this.controller,
      this.focusNode,
      this.isInt = false,
      this.isnum = false,
      this.isPercentage = false,
      this.props,
      this.alignment = MainAxisAlignment.spaceBetween,
      this.width = 200})
      : super(key: key);

  @override
  State<TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<TextFieldRow> {
  bool isEditable = true;

  @override
  void initState() {
    if (widget.initialValue != null && widget.controller != null) {
      widget.controller!.text = widget.initialValue!.toString();
    }
    if (widget.props != null) {
      Map props = widget.props!;
      if (props.containsKey("isEditable") && props["isEditable"] == false) {
        isEditable = false;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      width: 350,
      child: Row(mainAxisAlignment: widget.alignment, children: [
        Text(
          "${widget.label}:",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          isEditable
              ? SizedBox(
                  height: 30,
                  width: widget.width,
                  child: buildTextFormField())
              : Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(widget.initialValue?.toString() ?? "-"),
                    IconButton(
                    onPressed: () {
                      setState(() {
                        isEditable = !isEditable;
                      });
                    },
                    icon: const Icon(Icons.edit),
                    iconSize: 15,
                    splashRadius: 15,
                  )
                ]),
        ])
      ]),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
                  initialValue: widget.controller == null
                      ? widget.initialValue?.toString()
                      : null,
                  focusNode: widget.focusNode,
                  onChanged: widget.onChanged != null && widget.isnum
                      ? (value) => widget.onChanged!(num.tryParse(value))
                      : widget.onChanged,
                  decoration: InputDecoration(
                    //Add isDense true and zero Padding.
                    //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    //Add more decoration as you want here
                    //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                  ),
                  controller: widget.controller,
                  keyboardType: widget.isnum
                      ? const TextInputType.numberWithOptions(
                          decimal: true, signed: false)
                      : null,
                  inputFormatters: widget.isnum
                      ? [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[\d.,]")),
                          TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                            try {
                              final text =
                                  newValue.text.replaceAll(RegExp(r','), ".");
                              num numValue = 0;
                              if (text.isNotEmpty) {
                                numValue = num.parse(text);
                              }
                              if (widget.isPercentage &&
                                  (numValue > 100 || numValue < 0)) {
                                return oldValue;
                              }
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ]
                      : null,
                );
  }
}
