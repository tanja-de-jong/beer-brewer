import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  final void Function()? onClose;

  const Label({Key? key, required this.text, required this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text),
          SizedBox(width: 5),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close,
              size: 15.0,
            ),
          )
        ]));
  }
}
