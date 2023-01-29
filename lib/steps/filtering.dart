import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/store.dart';

class FilterStep extends StatefulWidget {
  final Batch batch;

  const FilterStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<FilterStep> createState() => _FilterStepState();
}

class _FilterStepState extends State<FilterStep> {
  late Recipe recipe;
  late Batch batch;
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Til de filterzak uit de pan en laat deze erboven uitlekken. Gebruik eventueel een vergiet.",
      "Vul indien nodig de hoeveelheid water aan."
    ]) {
      steps[text] = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      ...steps.keys.map((step) => Row(children: [Checkbox(value: steps[step], onChanged: (value){
        setState(() {
          steps[step] = !(steps[step] ?? true);
        });
      }), Text(step)])),
    ]);
  }
}
