import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntTextFieldRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final bool isDouble;

  const IntTextFieldRow({Key? key, required this.label, this.isDouble = false, this.alignment = MainAxisAlignment.spaceBetween}) : super(key: key);

  @override
  State<IntTextFieldRow> createState() => _IntTextFieldRowState();
}

class _IntTextFieldRowState extends State<IntTextFieldRow> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: widget.alignment, children: [
      Text(
        "${widget.label}:",
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      SizedBox(height: 30, width: 80, child: TextField(
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
      ))
    ],);
  }
}