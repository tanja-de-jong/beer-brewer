import 'package:flutter/material.dart';
import 'TextFieldRow.dart';

class DoubleTextFieldRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final num? initialValue;
  final Function(dynamic)? onChanged;
  final TextEditingController? controller;
  final bool isPercentage;
  final Map? props;
  final double width;

  const DoubleTextFieldRow({Key? key, required this.label, this.initialValue, this.onChanged, this.controller, this.isPercentage = false, this.props, this.alignment = MainAxisAlignment.spaceBetween, this.width = 200}) : super(key: key);

  @override
  State<DoubleTextFieldRow> createState() => _DoubleTextFieldRowState();
}

class _DoubleTextFieldRowState extends State<DoubleTextFieldRow> {
  @override
  Widget build(BuildContext context) {
    return TextFieldRow(label: widget.label, initialValue: widget.initialValue, controller: widget.controller, isnum: true, isPercentage: widget.isPercentage, props: widget.props, alignment: widget.alignment, onChanged: widget.onChanged, width: widget.width);
  }
}