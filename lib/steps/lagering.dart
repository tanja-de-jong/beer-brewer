import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/store.dart';
import '../form/TextFieldRow.dart';
import '../models/batch.dart';
import '../models/recipe.dart';

class LageringStep extends StatefulWidget {
  final Batch batch;

  const LageringStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<LageringStep> createState() => _LageringStepState();
}

class _LageringStepState extends State<LageringStep> {
  late Batch batch;
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Zet de emmer een week in de koelkast."
    ]) {
      steps[text] = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      ...steps.keys.map((step) => Row(children: [Checkbox(value: steps[step], onChanged: (value){
        setState(() {
          steps[step] = !(steps[step] ?? true);
        });
      }), Text(step)])),
      SizedBox(height: 20),
      TextFieldRow(
        label: "Datum",
        initialValue: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        onChanged: (value) {
          setState(() {
            Store.date = DateFormat("dd-MM-yyyy").parse(value);
          });
        },
      ),
    ]);
  }
}