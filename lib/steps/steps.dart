import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Steps extends StatefulWidget {
  final List<String> steps;
  final String title;
  final bool subgroup;

  const Steps({Key? key, required this.steps, this.title = "Stappen", this.subgroup = false}) : super(key: key);

  @override
  State<Steps> createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  Map<String, bool> steps = {};

  @override
  void initState() {
    for (String text in widget.steps) {
      steps[text] = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.title, style: widget.subgroup ? const TextStyle(decoration: TextDecoration.underline) : TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      ...steps.keys.map((step) => CheckboxListTile(
        dense: true,
            contentPadding: EdgeInsets.all(0),
            title: Transform.translate(
    offset: const Offset(-20, 0),
    child: Text(step)),
            value: steps[step],
            onChanged: (newValue) {
              setState(() {
                steps[step] = !(steps[step] ?? true);
              });
            },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          )),
    ]);
  }
}
