import 'package:flutter/material.dart';
import 'TextFieldRow.dart';

class DoubleTextFieldRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final double? initialValue;
  final Function(dynamic)? onChanged;
  final TextEditingController? controller;

  const DoubleTextFieldRow({Key? key, required this.label, this.initialValue, this.onChanged, this.controller, this.alignment = MainAxisAlignment.spaceBetween}) : super(key: key);

  @override
  State<DoubleTextFieldRow> createState() => _DoubleTextFieldRowState();
}

class _DoubleTextFieldRowState extends State<DoubleTextFieldRow> {
  @override
  Widget build(BuildContext context) {
    return TextFieldRow(label: widget.label, initialValue: widget.initialValue, controller: widget.controller, isDouble: true, alignment: widget.alignment, onChanged: widget.onChanged);
  }
}