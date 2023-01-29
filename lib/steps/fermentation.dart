import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/store.dart';

class FermentationStep extends StatefulWidget {
  final Batch batch;

  const FermentationStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<FermentationStep> createState() => _FermentationStepState();
}

class _FermentationStepState extends State<FermentationStep> {
  late Batch batch;
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Giet het (zo helder mogelijke) wort in de schone, steriele vergistingsemmer.",
      "Meet het SG met de refractometer.",
      "Voeg de gist toe en roer goed door.",
      "Sluit de emmer af, vul het waterslot voor 3/4 met water en plaats deze in het deksel."
      "Zet de emmer 2 tot 3 weken in een donkere ruimte met een temperatuur tussen ${batch.getFermentationTemperature()}."
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
      }), Expanded(child: Text(step))])),
      SizedBox(height: 20),
      DoubleTextFieldRow(label: "SG", onChanged: (value) {
        setState(() {
          Store.startSG = value;
        });
      })
    ]);
  }
}
