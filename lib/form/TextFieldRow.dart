import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final bool isInt;
  final bool isDouble;
  final dynamic? initialValue;
  final Function(dynamic)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const TextFieldRow({Key? key, required this.label, this.initialValue, this.onChanged, this.controller, this.focusNode, this.isInt = false, this.isDouble = false, this.alignment = MainAxisAlignment.spaceBetween}) : super(key: key);

  @override
  State<TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<TextFieldRow> {

  @override
  void initState() {
    if (widget.initialValue != null && widget.controller != null) {
      widget.controller!.text = widget.initialValue!.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 350, child: Row(mainAxisAlignment: widget.alignment, children: [
      Text(
        "${widget.label}:",
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      Column(children: [
      SizedBox(height: 30, width: 200, child: TextFormField(
        initialValue: widget.controller == null ? widget.initialValue?.toString() : null,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged != null && widget.isDouble ? (value) => widget.onChanged!(double.tryParse(value)) : widget.onChanged,
        decoration: InputDecoration(
          //Add isDense true and zero Padding.
          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
          isDense: true,
          contentPadding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(8),
          ),
          //Add more decoration as you want here
          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
        ),
        controller: widget.controller,
        keyboardType: widget.isDouble ?
        const TextInputType.numberWithOptions(
            decimal: true, signed: false) : null,
        inputFormatters: widget.isDouble ? [
          FilteringTextInputFormatter.allow(
              RegExp(r"[\d.,]")),
          TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                try {
                  final text = newValue.text
                      .replaceAll(RegExp(r','), ".");
                  if (text.isNotEmpty) {
                    double.parse(text);
                  }
                  return newValue;
                } catch (e) {}
                return oldValue;
              }),
        ] : null,
      )),
        SizedBox(height: 5)
    ])
    ]),);
  }
}